function di = rtDIInterp(optics,wavelength)
%Interpolate the ray trace spatial distortion data to a wavelength value
%
%   di = rtDIInterp(optics,wavelength)
%
% This function returns the geometric distortion data from the nearest
% wavelength value. 
%
% The distorted image (di) height function varies with wavelength. The
% distortions are typically computed in Zemax at a few wavelengths and
% stored in the optics.rayTrace.geometry subfields. 
%
% We could linearly interpolate between wavelengths, I suppose.
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also: rtRIInterp, rtGeometry, t_oiRTCompute


% Examples:
%{
oi = oiCreate('raytrace');
wavelength = 500;
di = rtDIInterp(oiGet(oi,'optics'),wavelength);
%}
%{
% Plot the distortion
oi = oiCreate('raytrace');
rtPlot(oi,'distortion');
%}

%% Distortion as a function of distance for each wavelength

di = [];

% The distorted image height is in the ray trace variable.
% distimght(fieldHeight,wave)
distimght = opticsGet(optics,'rtDistortion Function');
if isempty(distimght), return; end

% This is the wavelength used for geometric calculations?
wave = opticsGet(optics,'rtGeom Wavelength');

% Use a nearest neighbor method.  We could linearly interpolate, I suppose
[~, waveIdx] = min(abs(wavelength - wave));

di = distimght(:,waveIdx);  %Correct (1 Wave, All Fields)

end
