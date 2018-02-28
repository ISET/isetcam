function [outIrrad, oi] = rtPrecomputePSFApply(oi,angStep)
%Apply position dependent point spread function to an irradiance image
%
%   [outIrrad, oi] = rtPrecomputePSFApply(oi, angSteps)
%
% rtPrecomputePSFApply performs PSF interpolation to optical image
% irradiance data. The point spread is a function of each pixel's field
% height and angle. 
%
% PSFs are pre-computed for each each wavelength in the OI using
% rtPrecomputePSF.  The precomputed angles and field height samples can be
% relatively coarse.  These precomputed PSFs are interpolated to the pixel
% resolution of the OI.
%
% The PSF applied to a pixel is specific to the irradiance wavelength; the
% PSF is the weighted sum of the four radial and angle PSFs that surround
% the pixel. The code first interpolates for angle, and then for radial
% position.
%
% See also:  rtPrecomputePSF, s_opticsRTSynthetic, s_opticsRTPSFView.m
%
% Examples
%   scene = vcGetObject('scene');
%   oi = vcGetObject('oi'); 
% % Precompute the psf
%   angStep = 10; psfStruct = rtPrecomputePSF(oi,angStep);
%   oi = oiSet(oi,'psfStruct',psfStruct);
%
% % Call this routine via  opticsRayTrace
%   oi = opticsRayTrace(scene,oi);
%   ieAddObject(oi); oiWindow;
%
% Copyright ImagEval, LLC, 2005


%% Check the parameters, possibly precompute the shift-variant PSF
if ieNotDefined('oi'), error('OI required'); end

% Get the shift-variant PSF (svPSF) from the OI, or precompute it.
% the svPSF dimensions are svPSF.psf{angle,fieldHeight,wavelength} 
svPSF = oiGet(oi,'psfStruct');
if isempty(svPSF)
    if ieNotDefined('angStep'), angStep = 10; end  % 10 deg angle sampling
    svPSF = rtPrecomputePSF(oi,angStep);
    oi = oiSet(oi,'psfStruct',svPSF);
end
% Have a look at the psf functions we computed.
% vcNewGraphWin; 
% for ii=1:size(svPSF.psf,2), imagesc(svPSF.psf{1,ii,1}), axis image; pause(0.3); end
% vcNewGraphWin; imagesc(svPSF.psf{1,end,1})
% These are across the various angles
% vcNewGraphWin; 
% for ii=1:size(svPSF.psf,1), imagesc(svPSF.psf{ii,end,1}); axis image; pause(0.3); end

% Get optics and validate that it has ray trace information 
optics = oiGet(oi,'optics');
if isempty(opticsGet(optics,'rayTrace'))
    errordlg('No ray trace information.');
    return;
end

%% Properties of the optical image
% Get some parameters
inIrrad       = double(oiGet(oi,'photons')); %figure; imageSPD(inIrrad)
imSize        = oiGet(oi,'size');
wavelength    = oiGet(oi,'wavelength');
nWave         = oiGet(oi,'nwave');

% Figure out the positions of the oi point samples I think we know because
% the geometry and so forth prior to this point.
sSupport = oiGet(oi,'spatial support','mm');
xSupport = sSupport(:,:,1);

% The flip here makes large values of y the upper part of the image for
% axis xy rendering.
ySupport = flipud(sSupport(:,:,2));

%% Determine the field angle and height at each oi sample position.
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
% I am not sure that this is right. perhaps this be from the oi structure
% of psfield heights?
imgHeight = opticsGet(optics,'rt Psf Field Height','mm');
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
% other parameters.  This validation checks that we are still OK and
% recomputes if needed.
xGrid = rtPSFGrid(oi,'mm');
psfSize = size(xGrid);
rtPSF = oiGet(oi,'sampledRTpsf');
if size(rtPSF{1,1,1}) ~= psfSize
    handles = ieSessionGet('opticalImageHandle');
    ieInWindowMessage('Recomputing PSF to match oi sampling. ',handles,[]);
    
    psfStruct = rtPrecomputePSF(oi,oiGet(oi,'psfAngleStep'));
    if isempty(psfStruct)
        warndlg('Scene is undersampled.  No ray trace blurring applied');
        outIrrad = double(inIrrad); 
        return;
    end
    ieInWindowMessage('',handles,[]);
    oi = oiSet(oi,'psfStruct',psfStruct);
    % Get the PSFs again, this time with the right size
    rtPSF = oiGet(oi,'sampledRTpsf');
end

%% Allocate space for the output irradiance after applying the svPSF

% This should be an oiPad call that will correctly adjust the new
% height of the image!!!

% This grid matches the irradiance image spatial sampling
%
% The output irradiance image is padded with extra rows and columns to
% permit point spread blurring beyond the edge of inIrrad. The inIrrad
% positions begin at (extraRow/2 + 1, extraCol/2 + 1) in the outIrrad data.
extraRow = ceil(psfSize(1)); extraRow = 2*ceil(extraRow/2);
extraCol = ceil(psfSize(2)); extraCol = 2*ceil(extraCol/2);
oi = oiPad(oi,[extraRow,extraCol,0]);
outIrrad = double(zeros(imSize(1)+extraRow,imSize(2)+extraCol,length(wavelength)));
%{
% Prior to Feb. 27 2018 the code below was used, without the oiPad.
% This introduced an error: the size of the optical image was not
% adjusted to account for the padding as is done in oiPad. 
% MH pointed out the error.  BW fixed.
extraRow = ceil(1.5*psfSize(1)); extraRow = 2*ceil(extraRow/2);
extraCol = ceil(1.5*psfSize(2)); extraCol = 2*ceil(extraCol/2);
outIrrad = double(zeros(imSize(1)+extraRow,imSize(2)+extraCol,length(wavelength)));
%}

%% Calculate the shift-variant summation of irradiance and blurring
% Loop over wavelengths, image height, and image angles.
nFieldHeights = length(imgHeight);
showWaitBar = ieSessionGet('waitbar');
if showWaitBar
    str = sprintf('Applying psfs: %.0f heights and %.0f waves',nFieldHeights,nWave);
    wBar = waitbar(0,str);
end

for ww=1:nWave
    % Settle on a wavelength, indexed by ww
    rExt = floor(psfSize(1)/2);
    cExt = floor(psfSize(2)/2);
    
    % This is the input irradiance at the current wavelength.
    % The wavelength indices always match the precomputed PSFs.
    thisIrrad = inIrrad(:,:,ww);   % vcNewGraphWin; imagesc(thisIrrad)
    thisOut   = zeros(size(outIrrad,1),size(outIrrad,2));
    for rr = 2:nFieldHeights
        % Settle on a field height, indexed by rr
        
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
            
            % Place the result in the proper row and column of the output. 
            % if isodd(psfSize)
            if mod(psfSize,2)
                outRow = ((r1(jj) - rExt):(r1(jj) + rExt)) + extraRow/2;
                outCol = ((c1(jj) - cExt):(c1(jj) + cExt)) + extraCol/2;
            else
                outRow = ((r1(jj) - (rExt-1)):(r1(jj) + rExt)) + extraRow/2;
                outCol = ((c1(jj) - (cExt-1)):(c1(jj) + cExt)) + extraCol/2;
            end
            
            % This line is very slow because it is a sum between a very
            % large result and something else.  We should find a way to
            % speed this up.
            thisOut(outRow,outCol) = thisOut(outRow,outCol) + out;
            % Used to have:
            %  outIrrad(outRow,outCol,ww) = outIrrad(outRow,outCol,ww) + out;
            % But such an assignment is pretty slow.  So we give up some
            % space and speed it up.
            % vcNewGraphWin; imagesc(outIrrad(:,:,ww)); colormap(gray);
            % axis image
        end
    end
    outIrrad(:,:,ww) = thisOut;
end

% vcNewGraphWin; imageSPD(outIrrad);
if showWaitBar, close(wBar); end

end
