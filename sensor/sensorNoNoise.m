function sensorNN = sensorNoNoise(sensor);
%Set sensor noise to zero (apart from photon noise)
%
%    sensorNN = sensorNoNoise(sensor);
%
% This routine preserves the all other sensor parameters.  It is used in
% waveband calculations to produce a noise-free version of the current
% sensor.
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end

sensorNN   = sensor;
pixelNN    = sensorGet(sensorNN,'pixel');

sensorNN    = sensorSet(sensorNN,'prnulevel',0);
sensorNN    = sensorSet(sensorNN,'dsnulevel',0);
sensorNN    = sensorSet(sensorNN,'quantizationmethod','analog');
pixelNN     = pixelSet(pixelNN,'readNoiseVolts',0);
pixelNN     = pixelSet(pixelNN,'darkVoltage',0);
sensorNN    = sensorSet(sensorNN,'pixel',pixelNN);

return;