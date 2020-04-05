function di = rtDIInterp(optics,wavelength)
%Interpolate the ray trace spatial distortion data to a wavelength value
%
%   di = rtDIInterp(optics,wavelength)
%
% The distorted image height function varies with wavelength. The
% distortions are typically computed at only a few wavelengths and stored
% in the optics.rayTrace.geometry subfields. This return the distortion
% data from the nearest wavelength value.
%
% Some day we could linearly interpolate between wavelengths, I suppose.
%
% Example:
%      wavelength = 500;
%      di = rtDIInterp(optics,wavelength);
%
% Copyright ImagEval Consultants, LLC, 2003.

di = [];

% The distorted image height is in the ray trace variable.
% Returned units are:
distimght = opticsGet(optics,'rtDistortionFunction');
if isempty(distimght), return; end

% This is the wavelength used for geometric calculations?
wave = opticsGet(optics,'rtGeomWavelength');

% Use a nearest neighbor method.  We could linearly interpolate, I suppose
[v, waveIdx] = min(abs(wavelength - wave));
%di = distimght(:,waveIdx); %Incorrect (Takes a single Field Ht)
di = distimght(waveIdx,:);  %Correct (1 Wave, All Fields)

return;
