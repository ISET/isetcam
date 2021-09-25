function OImax = oiExtractBright(oi)
%Extract brightest pixel from an optical image and return it as an OI
%
%   OImax = oiExtractBright([oi])
%
% Make a 1 pixel optical image with a spectral illumination of the
% highest illuminance pixel.  The optics settings are adjusted so that
% OTF and off-axis computations are skipped. This is used in setting
% exposure duration (autoExposure) and other OI evaluations.
%
% Example:
%  OImax = oiExtractBright;
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('oi'), oi = vcGetObject('OI'); end

% Find the brightest part of the scene
sz = oiGet(oi,'size');
illuminance = oiGet(oi,'illuminance');

% If illuminance has not been computed, compute it here
[~,ind] = max(illuminance(:));
[rect(2),rect(1)] = ind2sub(sz,ind);
rect(3) = 1; rect(4) = 1;

% Now, we crop the data to form a small opticalimage  containing only the
% highest illuminance.
OImax = oiCrop(oi,rect);

% We adjust the optics
optics = oiGet(OImax,'optics');
optics = opticsSet(optics,'otfmethod','skip');
optics = opticsSet(optics,'offaxismethod','skip');

OImax = oiSet(OImax,'optics',optics);

end