function PE = photometricExposure(oi, sensor)
%Compute photometric exposure (lux-sec) for a sensor and optical image
%
%   PE = photometricExposure(oi,sensor)
%
% The photometric exposure is the product of the mean  illuminance in
% the optical image (sensor illuminance, lux) and the exposure duration
% (sec).  The value accounts for the scene luminance and the optics and the
% sensor exposure duration.
%
%Example
%    photometricExposure
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('oi'), oi = vcGetObject('OI'); end
if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end

PE = oiGet(oi, 'meanIlluminance') * sensorGet(sensor, 'exposureTime');

return;