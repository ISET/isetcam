function optics = rtSynthetic(oi,rayTrace,spreadLimits,xyRatio)
%Create synthetic ray trace data for testing
%
%  optics = rtSynthetic([oi],[rayTrace],[spreadLimits],[xyRatio])
%
% All of the rayTrace fields are filled in using simple values.  This is
% for testing the ray trace computation.
%
% The point spreads are bivariate normals that increase from center to
% periphery.  Over time, we will add parameters to the function that
% control the bivariate normal growth with field height as well as other
% parameters. 
%
%Example
%  oi = vcGetObject('oi'); 
%  optics = rtSynthetic(oi,[],[3 5],0.3);
%  oi = oiSet(oi,'optics',optics); oi = oiSet(oi,'name','Increasing-Gauss');
%  ieAddObject(oi); oiWindow;
%
%  optics = rtSynthetic([],[],[3 3],0);
%  oi = oiSet(oi,'optics',optics); oi = oiSet(oi,'name','Fixed-Gauss');
%  ieAddObject(oi); oiWindow;
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('oi'), oi = vcGetObject('oi'); end
if ieNotDefined('rayTrace')
    % Rebuild optics.rayTrace general values.
    rayTrace.program = 'Zemax';
    rayTrace.lensFile = 'Synthetic Gaussian';
    rayTrace.referenceWavelength = 500;  %nm
    rayTrace.objectDistance = 10;           % mm
    rayTrace.mag = 0.10;
    rayTrace.fNumber = 4.8;
    rayTrace.effectiveFocalLength = 3;  %mm
    rayTrace.effectiveFNumber = 4.2;
    rayTrace.maxfov = 30;
end
if ieNotDefined('spreadLimits'), spreadLimits = [1,4]; end
if ieNotDefined('xyRatio'), xyRatio = 1; end   

% Field height and wavelenth for all the functions
fieldHeight = (0:0.05:1);     %mm
% wavelength = oiGet(oi,'wave');   %nm
wavelength = [450 550 650];   %nm

%% Make the image height distortion information
d = fieldHeight(2)*(fieldHeight/fieldHeight(2)).^0.85;
geometry.function    = repmat(d(:),1,length(wavelength));
geometry.fieldHeight = fieldHeight(:);
geometry.wavelength  = wavelength(:);

%% Make relative illumination information
r = 1 - (fieldHeight/(10*fieldHeight(end))).^0.85;
relIllum.function = repmat(r(:),1,length(wavelength));
relIllum.fieldHeight = fieldHeight(:);
relIllum.wavelength = wavelength(:);

%% Create point spread information
N = 128;   % 128 samples, spaced 0.25 microns

% This has to do with the spread increase over field height
spread     = (spreadLimits(2)-spreadLimits(1));
% normFH  = (fieldHeight/max(fieldHeight)).^(2.5);
normFH  = (fieldHeight/max(fieldHeight));

% The 4 is here because 4 samples is a micron
xSpread = 4*(spreadLimits(1) + normFH*spread); 

% The ySpread is proportional to the xSpread.
ySpread = xyRatio * (xSpread .* (1 + normFH));

nH = length(fieldHeight);
psf.function = zeros(N,N,nH,length(wavelength));
for ii=1:nH
    for jj = 1:length(wavelength)
        psf.function(:,:,ii,jj) = biNormal(xSpread(ii),ySpread(ii),0,N);
    end
end
psf.fieldHeight   = fieldHeight(:);
psf.sampleSpacing = [2.5000e-004 2.5000e-004];  %mm
psf.wavelength = wavelength(:);
% for ii=1:nH, vcNewGraphWin; imagesc(psf.function(:,:,ii,1); end

% Build the new optics structure
optics = oiGet(oi,'optics');
optics = opticsSet(optics,'model','ray trace');
optics = opticsSet(optics,'ray trace',rayTrace);
optics = opticsSet(optics,'rt geometry',geometry);
optics = opticsSet(optics,'rt relIllum',relIllum);
optics = opticsSet(optics,'rt name','Synthetic Gaussian');
optics = opticsSet(optics,'rt PSF',psf);

return;

