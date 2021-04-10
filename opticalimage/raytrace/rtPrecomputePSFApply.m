function oi = rtPrecomputePSFApply(oi,angStep)
% Apply position dependent point spread function to an irradiance image
%
%   oi = rtPrecomputePSFApply(oi, angSteps)
%
% Description:
%  rtPrecomputePSFApply uses the PSFs to blur the optical image
%  irradiance data. The point spread is a function of each pixel's
%  field height and angle. The PSFs are pre-computed for each each
%  wavelength using rtPrecomputePSF.  That function precomputes PSFs
%  so that they are interpolated to the pixel resolution of the OI.
%  The precomputed angles and field height samples can be relatively
%  coarse.
%
%  The PSF applied to a pixel is specific to the irradiance
%  wavelength; the PSF is the weighted sum of the four radial and
%  angle PSFs that surround the pixel. The code first interpolates for
%  angle, and then for radial position.
%
% Copyright ImagEval, LLC, 2005
%
% See also:  rtPrecomputePSF, s_opticsRTSynthetic, s_opticsRTPSFView.m

% Examples
%{
  scene = sceneCreate('slanted bar',[384,384]);
  scene = sceneSet(scene,'fov',2); ieAddObject(scene);
  oi = oiCreate('raytrace');
% Precompute the psf
  angStep = 10; psfStruct = rtPrecomputePSF(oi,angStep,[0,0],scene);
  oi = oiSet(oi,'psfStruct',psfStruct);
% Call this routine via opticsRayTrace directly, rather than oiCompute
  oi = opticsRayTrace(scene,oi);
  ieAddObject(oi); oiWindow;
%}


%% Check the parameters, possibly precompute the shift-variant PSF
if ieNotDefined('oi'), error('OI required'); end

% Validate that optics has ray trace information 
if isempty(oiGet(oi,'optics rayTrace'))
    errordlg('No ray trace information.');
    return;
end

% Get the shift-variant PSF (svPSF) from the OI
% the svPSF dimensions are svPSF.psf{angle,fieldHeight,wavelength} 
svPSF = oiGet(oi,'psfStruct');

% If it is empty, precompute it.
if isempty(svPSF)
    if ieNotDefined('angStep'), angStep = 10; end  % 10 deg angle sampling
    svPSF = rtPrecomputePSF(oi,angStep);
    oi = oiSet(oi,'psfStruct',svPSF);
end

% You can visualize the psfs{angle,field height,wave}
%{
% The PSFs across field height.
vcNewGraphWin; 
for ii=1:size(svPSF.psf,2), imagesc(svPSF.psf{1,ii,1}), axis image; pause(0.3); end
%}
%{
% One PSF
vcNewGraphWin; 
imagesc(svPSF.psf{1,end,1})
%}
%{
% The PSFs across angles
vcNewGraphWin; 
for ii=1:size(svPSF.psf,1), imagesc(svPSF.psf{ii,end,1}); axis image; pause(0.3); end
%}

%% Properties of the input optical image

% Get parameters from the input, pre-blurred
inIrrad       = double(oiGet(oi,'photons')); %figure; imageSPD(inIrrad)
wavelength    = oiGet(oi,'wavelength');
nWave         = oiGet(oi,'nwave');

% Figure out the positions of the oi point samples I think we know because
% the geometry and so forth prior to this point.
sSupport = oiGet(oi,'spatial support','mm');
xSupport = sSupport(:,:,1);

% The flip here makes large values of y the upper part of the image for
% axis xy rendering.
ySupport = flipud(sSupport(:,:,2));

% Determine the field angle and height at each oi sample position.
[dataAngle,dataHeight] = cart2pol(xSupport,ySupport);

% Force data between 0-360 deg and to a resolution of 1 deg
dataAngle = round(ieRad2deg(dataAngle + pi));

% Not sure why we need this, but we do. Maybe because of the center
dataAngle(dataAngle == 0) = 1;  
% vcNewGraphWin; imagesc(dataHeight)
% vcNewGraphWin; imagesc(dataAngle)

% Not sure it is necessary to save space. 
dataAngle  = double(dataAngle); 
dataHeight = double(dataHeight);

%% Reduce imgHeights to those levels within the image height

% Some confusion.  There are the psf derived from, say, Zemax in the
% optics. Then there are the psf structure values that are pre-computed.
% This one is from the Zemax (or other) calculation.
% 
% I am not sure that this is right. Perhaps this is from the oi structure
% of psfield heights?
imgHeight = oiGet(oi,'optics rt Psf Field Height','mm');
imgHeight = rtSampleHeights(imgHeight,dataHeight);
fprintf('%.0f eccentricity bands\n',length(imgHeight));

% Build the LUT for image angles to the indices in svPSF.sampAngles. The
% LUT is a matrix with 360 rows and 2 columns.  The first column is an
% index that maps each deg into the nearest svSamp.sampAngles. The second
% column is a weight for how much that value should matter.  1-weight
% should be attached to the next highest sampAngle value.
aLUT = rtAngleLUT(svPSF);
% vcNewGraphWin; plot(aLUT(:,1))

%% Validate the interpolated ray trace PSF stored in oi.psf

% The precomputed svPSF can become out of sync if we change the scene or
% other parameters.  This validation checks that the PSFs are properly
% sampled.
xGrid = rtPSFGrid(oi,'mm');
psfSize = size(xGrid);
rtPSF = oiGet(oi,'sampledRTpsf');
if size(rtPSF{1,1,1}) ~= psfSize
    % Not a match.  Recompute.
    app = ieSessionGet('oi window');
    ieInWindowMessage('Recomputing PSF to match oi sampling. ',app,[]);
    
    psfStruct = rtPrecomputePSF(oi,oiGet(oi,'psfAngleStep'));
    if isempty(psfStruct)
        % Even worse.  The PSF is basically an impulse.  No need to
        % blur.
        warndlg('Scene is undersampled.  No blurring applied');
        return;
    end
    
    % Clear message.
    % Get the PSFs again, this time with the right size
    ieInWindowMessage('',app,[]);
    oi = oiSet(oi,'psfStruct',psfStruct);
    rtPSF = oiGet(oi,'sampledRTpsf');
end

%% Allocate space for the output irradiance after applying the svPSF

% The input spatial grid is the irradiance after geometric correction.
% The PSF from the input irradiance positions will be added into the
% output irradiance positions.

% These variables represent the extent of the PSF in pixels. (Used to
% be inside the loop.  Moved it out March 6, 2018).
rExt = floor(psfSize(1)/2);
cExt = floor(psfSize(2)/2);

% We blur, so we add some extra rows and columns to catch the
% light that spreads. Thus, the first point in the input radiance will
% be placed in an interior point in the output radiance. The extra
% rows and columns are both pre- and post-, so that initial position
% will be this:
%
%    (extraRow/2 + 1, extraCol/2 + 1)
%
% The assignment to the output point is determined within the main
% computational loop. 

% How many extra rows should we add to each size of the image?  We
% need at least as many as half the extent of the point spread.  We
% add two more columns and rows, to be safe. 

% This one worked for a while.  But not needed any more.
% extraRow = ceil(psfSize(1)); extraRow = 2*ceil(extraRow/2);
% extraCol = ceil(psfSize(2)); extraCol = 2*ceil(extraCol/2);
extraRow = ceil(rExt) + 2; extraRow = 2*ceil(extraRow/2);
extraCol = ceil(cExt) + 2; extraCol = 2*ceil(extraCol/2);
oi = oiPad(oi,[extraRow,extraCol]);
% oiGet(oi,'size')
% These should match
%{
oiGet(oi,'hfov')
spaceRes = oiGet(oi,'spatial resolution','um')
spaceRes(2) - oiGet(oi,'width','um')/oiGet(oi,'cols')
%}

% The stored hfov should match this computed hfov
%{
oiGet(oi,'hfov')
d = oiGet(oi,'optics focal length','um')
2*atand((oiGet(oi,'width','um')/2)/d)
%}

% Because we have padded (above), I think the outIrrad should be
% created this way: 
%
%   outIrrad = oiGet(oi,'photons'); size(outIrrad)
%
outIrrad = double(zeros(oiGet(oi,'row'),oiGet(oi,'col'),length(wavelength)));
% size(outIrrad)

% But instead, we are only adding extraRow once, not pre- and post
% (twice).  That's odd.
% This worked.
% outIrrad = double(zeros(imSize(1)+2*extraRow,imSize(2)+2*extraCol,length(wavelength)));

%% Calculate the shift-variant summation of irradiance and blurring
% Loop over wavelengths, image height, and image angles.
nFieldHeights = length(imgHeight);
showWaitBar = ieSessionGet('waitbar');
if showWaitBar
    str = sprintf('Applying psfs: %.0f heights and %.0f waves',nFieldHeights,nWave);
    wBar = waitbar(0,str);
end

for ww=1:nWave  % Settle on a wavelength, indexed by ww
    
    % This is the input irradiance at the current wavelength.
    % The wavelength indices always match the precomputed PSFs.
    thisIrrad = inIrrad(:,:,ww);   % vcNewGraphWin; imagesc(thisIrrad)
    thisOut   = zeros(size(outIrrad,1),size(outIrrad,2));
    
    for rr = 2:nFieldHeights    % Settle on a field height, indexed by rr    
        
        % Heights are in mm.  We convert to um.
        str = sprintf('Applying psfs: Wave: %.0f nm Height: %.0f (um)', ...
            wavelength(ww),imgHeight(rr)*1e3);
        if showWaitBar, wBar = waitbar(rr/nFieldHeights,wBar,str); end
        % The PSF data are PSF{Angle,ImageHeight,Wavelength}

        % Find all the points between the current and last image height.
        % These will be the two indices, rr and rr-1, into the PSF data.
        lBand1 = (dataHeight >= imgHeight(rr-1)) & (dataHeight < imgHeight(rr));
        %  vcNewGraphWin; image(lBand1); colormap(gray(2))
        
        [r1,c1] = find(lBand1);  % The 1 index doesn't make sense.
        % ind1 = find(lBand1);     % Indices into the data in the band

        % Every point gets a weight that define its distance from the two
        % heights that bound the sample position. We create an image of the
        % weights for the inner PSF at every output position.  Only the
        % weights within the current lBand1 matter.
        innerDistance = abs(dataHeight - imgHeight(rr-1));
        innerWeight = 1 - (innerDistance / (imgHeight(rr) - imgHeight(rr-1)));
        % vcNewGraphWin; imagesc(innerWeight.*lBand1);

        % The radial weight applied to the inner PSF. The outer PSF gets 
        % 1 - wgt1 
        % rWgt = innerWeight(ind1);
        % figure; hist(rWgt,50); % Fewer pixels near inner radius 

        for jj=1:length(r1)
            % For every point, jj, in the identified region, form a PSF
            % that is the weighted sum of four PSFs.  These are the four
            % corresponding to the position a little closer to the origin
            % and a little further, and the angles a little smaller and a
            % little larger than the angle of this point in the plane.
            
            % Weighted sum of the two points at common field heights and
            % wavelengths.
            %  aIdx = aLUT(dataAngle(ind1(jj)));
            %  aWgt = aLUT(dataAngle(ind1(jj)));
            aIdx = aLUT(dataAngle(r1(jj),c1(jj)),1);
            aWgt = aLUT(dataAngle(r1(jj),c1(jj)),2);
            % hold on; plot(r1(jj),c1(jj),'wo')
            %  Original:  An error
            % aIdx = aLUT(dataAngle(jj),1); aWgt = aLUT(dataAngle(jj),2);
            
            % Get the PSF at this index and the next for both angle and
            % image height.
            % These are the two angles. 
            tmpPSF1 = (aWgt*rtPSF{aIdx,rr-1,ww})+ ...
                ((1-aWgt)*rtPSF{aIdx+1,rr-1,ww});
            tmpPSF2 = (aWgt*rtPSF{aIdx,rr,ww})+ ...
                ((1-aWgt)*rtPSF{aIdx+1,rr,ww});
            % vcNewGraphWin; imagesc(tmpPSF1);
            % vcNewGraphWin; imagesc(tmpPSF2);

            % These are the two field heights.
            % I am not sure why we use rr-1 and rr,
            % but we use aIdx and aIdx+1.  Probably OK, but inelegant.
            % out =((rWgt(jj)*tmpPSF1)+ ((1-rWgt(jj))*tmpPSF2)).*thisIrrad(ind1(jj));
            rWgt = innerWeight(r1(jj),c1(jj));
            % rWgt = innerWeight(ind1(jj));  % Equivalent
            
            thisPSF =((rWgt*tmpPSF1) + ((1-rWgt)*tmpPSF2));
            out = thisPSF.*thisIrrad(r1(jj),c1(jj));
            % vcNewGraphWin; imagesc(thisPSF)
            % sum(thisPSF(:))
            
            % Place the result in the proper row and column of the
            % output irradiance. 
            % 
            % Logic:  The psf has an extent that covers -rExt:rExt. 
            % We must shift the (r1,c1) input position by extraRow/2 to
            % account for the row and column padding of the output.
            % The even/odd issue can probably be avoided
            % because psfSize is always even. if isodd(psfSize)
            if mod(psfSize,2)
                % Removed /2 on extraRow/2
                outRow = ((r1(jj) - rExt):(r1(jj) + rExt)) + extraRow;
                outCol = ((c1(jj) - cExt):(c1(jj) + cExt)) + extraCol;
            else
                outRow = ((r1(jj) - (rExt-1)):(r1(jj) + rExt)) + extraRow;
                outCol = ((c1(jj) - (cExt-1)):(c1(jj) + cExt)) + extraCol;
            end
            if min(outRow < 1), pause; end
            % This line is very slow because it is a sum between a very
            % large result and something else.  We should find a way to
            % speed this up.
            thisOut(outRow,outCol) = thisOut(outRow,outCol) + out;
            % Used to have:
            %
            % outIrrad(outRow,outCol,ww) = outIrrad(outRow,outCol,ww) + out;
            %
            % The big summation is slow.  So we give up some space to
            % speed the calculation.
            %
            % vcNewGraphWin; 
            % imagesc(outIrrad(:,:,ww)); colormap(gray); axis image
        end
    end
    outIrrad(:,:,ww) = thisOut;
end

oi = oiSet(oi,'photons',outIrrad);

%{
oiGet(oi,'hfov')
spaceRes = oiGet(oi,'spatial resolution','um')
spaceRes(2) - oiGet(oi,'width','um')/oiGet(oi,'cols')
oiGet(oi,'hfov')
2*atand((oiGet(oi,'width','um')/2) / oiGet(oi,'optics focal length','um'))
%}

% vcNewGraphWin; oiShowImage(oi);
if showWaitBar, close(wBar); end

end
