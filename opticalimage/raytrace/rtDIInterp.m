function di = rtDIInterp(optics,wavelength)
%Interpolate the ray trace spatial distortion data to a wavelength value
%
%   di = rtDIInterp(optics,wavelength)
%
% The distorted image (di) height function varies with wavelength. The
% distortions are typically computed in Zemax at only a few wavelengths and
% stored in the optics.rayTrace.geometry subfields. This function returns
% the distortion data from the nearest wavelength value.
%
% Some day we could linearly interpolate between wavelengths, I suppose.
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also
% 

% Examples:
%{
wavelength = 500;
di = rtDIInterp(optics,wavelength);
%}

di = [];

% The distorted image height is in the ray trace variable.
% Returned units are:
distimght = opticsGet(optics,'rtDistortionFunction');
if isempty(distimght), return; end

% This is the wavelength used for geometric calculations?
wave = opticsGet(optics,'rtGeomWavelength');

% Use a nearest neighbor method.  We could linearly interpolate, I suppose
[~, waveIdx] = min(abs(wavelength - wave));

di = distimght(:,waveIdx);  %Correct (1 Wave, All Fields)

end
