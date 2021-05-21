function di = rtDIInterp(optics,wavelength)
% Interpolate the ray trace spatial distortion data to a wavelength value
%
%   di = rtDIInterp(optics,wavelength)
%
% Description:
%  This function returns the geometric distortion data from the nearest
%  wavelength value. The distortions are typically computed in Zemax at a
%  few wavelengths and stored in the optics.rayTrace.geometry subfields.
%  The distortion units are millimeters.
%
%  The geometry slot contains the nominal field height (mm), wavelength
%  (nm), and the distortion function (mm). The distortion function is a
%  matrix that is (fieldHeight x wavelength).
%
%  We could linearly interpolate between wavelengths, I suppose.
%
% Inputs:
%   optics:      A ray trace optics structure
%   wavelength:  The chosen wavelength for the distortion
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also: rtRIInterp, rtGeometry, t_oiRTCompute, s_opticsRTGridLines

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
