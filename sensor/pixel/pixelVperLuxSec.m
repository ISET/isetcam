function [voltsPerLuxSec,luxsec,meanVolts,voltsPerAntiLuxSec,antiluxsec]...
    = pixelVperLuxSec(sensor,lightType)
%
% Compute pixel photometric sensitivity (volts per lux-sec)
%
%    [voltsPerLuxSec,luxsec,meanVolts] = pixelVperLuxSec([sensor])
%
% The photometric sensitivity is computed for each of the color sensors
% using a uniform equal energy light input. The value can change
%
% This routine is used to convert the pixelSNR graph from SNR vs. Volts to
% SNR vx. Lux-Sec.
%
% The value of photometrics sensitivity (V/lux-sec) depends on the
% spectral power distribution of the input.  The lightType variable
% chooses the light spectral power distribution.  By default, the SPD is
% equal energy.  It is also possible to use D65.
%
% See also pixelSNR, pixelSNRluxsec
%
% Example:
%   [vpLS,ls,meanV] = pixelVperLuxSec;
%   [vpLS,ls,meanV] = pixelVperLuxSec(sensor);
%
% Example: (both luxsec and antiluxsec)
%   [vpLS,ls,meanV,vpALS,als] = pixelVperLuxSec;
%
% Copyright ImagEval Consultants, LLC, 2003.

%TODO
% Should we make the spectral character of the light an option?

if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('lightType'), lightType = 'ee'; end

% The 0 flag at the end means don't add the OI to the list.  It will just
% be a local image.  The default OI is created with cos4th and diff turned
% off (skip). We should re-write the code with those parameters settable at
% creation time, I suppose.

% We used to use this scene.  Maybe we still should make this the default,
% for compatibility.  For IR, though, we changed to uniformEE.
wave = sensorGet(sensor,'wave');
switch lower(lightType)
    case 'ee'
        OI = oiCreate('uniformEE',[],[],0,32,wave);
    case 'd65'
        OI = oiCreate('uniformD65',[],[],0,32,wave);
end

% Make optics the same as in the currently selected scene?
% OI = sceneSet(OI,'optics',vcGetObject('optics'));

% Compute the mean lux
%[illuminance,lux] = oiCalculateIlluminance(OI);

[illuminance,lux,antilux] = oiCalculateIlluminance(OI);

% Find and store the auto-exposure time for this image.
level = 1;      % Level re: pixel voltage swing (1 means all the way)
saturationExposureTime = autoExposure(OI,sensor,level);

% Compute the lux-sec in the image.
luxsec = lux*saturationExposureTime;
antiluxsec = antilux*saturationExposureTime;

% Compute the full sensor response at the saturation exposure time
sensor = sensorSet(sensor,'autoexposure',saturationExposureTime);
sensor = sensorCompute(sensor,OI);

% Pull out the mean voltages of the sensor types
nSensors = sensorGet(sensor,'ncolors');
for ii=1:nSensors
    meanVolts(ii) = mean(sensorGet(sensor,'volts',ii));
end

% Calculate photometric sensitivity (V/(lux s)) for each of the sensor
% types.
voltsPerLuxSec = meanVolts / luxsec;

% Used for some IR calculations.  Mostly ignored.
voltsPerAntiLuxSec = meanVolts / antiluxsec;


return