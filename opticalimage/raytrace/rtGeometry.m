function oi = rtGeometry(oi,scene)
%Compute the irradiance with ray traced geometric distortion
%
%    oi = rtGeometry(oi,scene)
%
% Description:
%  The scene radiance is converted to an irradiance in the optical
%  image. Distortion and relative illumination are applied. The ray
%  trace parameters are stored in a ray tracing slot in the optics of
%  the oi. The data are derived from optics modeling programs such as
%  Code V and Zemax. 
%
% Example: 
%   scene = sceneCreate('gridlines');
%   oi = vcGetObject('oi'); optics = oiGet(oi,'optics');
%   oi = rtGeometry(oi,scene);
%   imageSPD(gImage);
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also:  s_opticsRTGridLines, t_oiRTCompute, rtDIInterp.m

% Programming notes:
%
% imght:  Is a set of spatial samples in units of meters that defines
% positions in the image plane where we will be distorting and relative
% illuminating.  0 is the optical axis of the image height.  We only need
% to sample out to the diagonal distance.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Image x-direction corresponds to i matrix row axis
% Image y-direction corresponds to j matrix column axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load Lens Ideal Image Height, Distorted Image Height, and 
% Relative Illumination Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
optics = oiGet(oi,'optics');

% Clear the display
app = ieSessionGet('oi window');
ieInWindowMessage('',app,[]);

%% This is the ideal geometrical irradiance with no geometric distortion.

% Irradiance is calculated point by point from the scene radiance.  
irradiance = oiCalculateIrradiance(scene,optics);
wavelength = sceneGet(scene,'wavelength');

%  Get the image height sample values from the ray trace optics
imght     = opticsGet(optics,'rtgeom field height','mm');       % mm
% distimght = opticsGet(optics,'rtgeomfunction');
% relillum  = opticsGet(optics,'rtrifunction');            
% nFieldPositions =size(distimght,1);

% These are the row,col,wavelength indices of the irradiance image.
[rowMax, colMax, nWave] = size(irradiance);

% We need to check that the current scene field of view is smaller than the
% maxfov of this optical calculation.

%  fovmax used to be fixed  2*26.2;   
fovmax = sceneGet(scene,'fov');     %Maximum horizontal field of view (deg) 
if fovmax > opticsGet(optics,'rtfov')
    str = sprintf('Scene FOV (%.0f) exceeds ray trace analysis (%.0f)',fovmax,opticsGet(optics,'rtfov'));
    ieInWindowMessage(str,oiHandles,[]);
    return;
end

% imgdiag = opticsGet(optics,'diagonal',fovmax,'mm');            % In millimmeters
% ywidth = opticsGet(optics,'imageheight',fovmax,'mm');            
xwidth = opticsGet(optics,'image width',fovmax,'mm');             

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% xwidth refers to the horizontal dimension, whereas imax is the index for
% rows. The rtGeometry applies relative illumination incorrectly and the
% bug appears. This can be easily checked by using a slender image as
% input. Say, a scene composed of 10 rows and 1000 columns with constant
% illumination      
% Fixed by H Gonzalez-Banos
%
dx = xwidth/colMax;      %x-width of pixel in mm
% dy=ywidth/jmax;      %y-width of pixel in mm
% pixelfov=fovmax/imax*xwidth/imgdiag*60;  %field of view of one pixel in arc minutes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define final geometric image space and final distorted 
% image space
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% It could be that we should just run the whole calculation on the padded
% image, instead of this section of the padded image.  This might simplify
% the code below.

% Padding the image here is a problem for the geometry.  We need to account
% for the field of view, if we pad.  I am not sure we need to pad.  So, for
% now, I have set zeropad to do not pad, and will do some more testing.

%zeropad=16;                            %zero padding size.  Figure out how to set this properly
zeropad = 0;
paddedRowMax = rowMax + 2*zeropad;        %number of rows in final geometric image space
paddedColMax = colMax + 2*zeropad;        %number of columns in final geometric image space
rowCenter=(paddedRowMax+1)/2;           %center row of final geometric image space
colCenter=(paddedColMax+1)/2;           %center column of final geometric image space

% Pixel distances and angles in pixel coordinates
r = (1:paddedRowMax) - rowCenter;
c = (1:paddedColMax) - colCenter;
[C,R] = meshgrid(c,r);
pixdist = sqrt(C.^2 + R.^2);
pixang = atan2(C,R);

%Pixel distance in real units (mm) to image center
pixdistUnits = pixdist*dx;           

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start of Loop to Apply Distortion and Relative 
% Illumination factor to Input Images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gImage=zeros(rowMax,colMax,nWave);      %intialize final distorted image space
for ww = 1:nWave
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Perform Least Squares Fit (Polynomial) to Distorted Image
    % Height Data.  This polynomial maps each position in the final image
    % into a position in the original image.  We obtain the irradiance data
    % in the final from these locations in the original image.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % The di values (mm) are the true location on the sensor for each field
    % height.  The units are mm.
    di = rtDIInterp(optics,wavelength(ww));
    %{
      vcNewGraphWin; plot(imght(:),di(:));
      grid on; axis square;identityLine;
    %}
    
    % We should find a way to validate the required polynomial degree and
    % illustrate with some examples.  When 8 is reduced to 4, we get real
    % problems.  This should be part of the presentation. We must linearly
    % interpolate for wavelength, first.
    
    % The polynomial order that we use here really matters.  For the Fish
    % EYE, pNum = 8 was a serious problem. pNum = 6 worked well for Fish Eye
    pNum = 8;
    if length(imght(:)) < 7
        if length(imght(:)) < 2
            error('Insufficient image height data');
        else
            pNum = length(imght(:)) - 2;
            warndlg(sprintf('Caution: polyfit reduced to %.0f.',pNum));
        end
    end
    % pNum is the polynomial degree
    % The distortion (di) are fitted to image height (imght).
    polyP = polyfit(di(:),imght(:),pNum);
    % figure; plot(polyval(polyP,di(:)),imght(:),'-o'); grid on
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Perform Least Squares Fit of Relative Illumination Data
    % to Distorted Image Height Data.  Here, again, we start with positions
    % in the final image and see how we take a value from the ideal
    % relative illumination spatial image.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % This is the fit to relative illumination. How do we know the polynomial degree?
    ri = rtRIInterp(optics,wavelength(ww));
    polyQ = polyfit(di(:),ri(:),2);
    % figure; plot(polyval(polyQ,di(:)),ri(:),'-x'); grid on

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Apply Distortion Shifts to Ideal Geometric Image.  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    paddedIrradiance = padarray(irradiance(:,:,ww),[zeropad,zeropad]);
    
    % This polynomial must have poly(0) = 0
    % imghttemp=p(1)*distimghttemp+p(2)*distimghttemp^2+p(3)*distimghttemp^3+p(4)*distimghttemp^4;
    imghttemp    = polyval(polyP,pixdistUnits);  %figure; mesh(imghttemp)
    relillumtemp = polyval(polyQ,pixdistUnits);
    
    % These are the coordinates of the distorted image data.  We interpolate
    % the irradiance values onto the grid, below.  
    padR = rowCenter + imghttemp.*cos(pixang)/dx;  padR = ieClip(padR,1,paddedRowMax);
    padC = colCenter + imghttemp.*sin(pixang)/dx;  padC = ieClip(padC,1,paddedColMax);
    
    % Bilinear Interpolation to determine pixel irradiance
    % This is the slowest part.  I think griddata is even slower, though.
    A = padR - floor(padR); 
    B = padC - floor(padC);
    distortedPaddedIrradiance = zeros(paddedRowMax,paddedColMax);
    for ii=1:(paddedRowMax)
        for jj=1:(paddedColMax)
            distortedPaddedIrradiance(ii,jj)=  ...
                relillumtemp(ii,jj)*(A(ii,jj)*B(ii,jj)*paddedIrradiance(ceil(padR(ii,jj)),ceil(padC(ii,jj)))+ ...
                A(ii,jj)*(1-B(ii,jj))*paddedIrradiance(ceil(padR(ii,jj)),floor(padC(ii,jj)))+ ...
                (1-A(ii,jj))*B(ii,jj)*paddedIrradiance(floor(padR(ii,jj)),ceil(padC(ii,jj)))+ ...
                (1-A(ii,jj))*(1-B(ii,jj))*paddedIrradiance(floor(padR(ii,jj)),floor(padC(ii,jj))));
        end
    end
    
    % Copy the central part of the intermediate calculation into the final
    % image that is returned.
    gImage(:,:,ww)=distortedPaddedIrradiance(zeropad+1:paddedRowMax-zeropad,zeropad+1:paddedColMax-zeropad);
    
end

% I think this is what should be returned.  And we should check that
% the size of the width is right!
oi = oiSet(oi,'photons',gImage);

% figure; imageSPD(gImage)

end