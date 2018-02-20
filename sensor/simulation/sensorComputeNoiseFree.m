function sensor = sensorComputeNoiseFree(sensor,oi)
%Compute the mean sensor voltage data from the optical image
%
%  sensor = sensorComputeNoiseFree(sensor,oi)
%
% We calculate the noise free voltage image for a sensor with the specified
% general characteristics.  The noise free voltage is in the 'volts' field
% of the sensor.  
%
% We prevent all types of noise we can think of. Specifically, we eliminate
%
%   * electrical and photon noise
%   * voltage saturation (clipping at the high end)
%   * quantization
%
% N.B. We do not prevent clipping at the low end.  This could happen if
% we set the analog offset to a positive number and then subtract it.
%
% This routine must be run for a specific integration time (no
% auto-exposure).  The user is warned if auto-exposure is on.
%
% Example:
%     oi = vcGetObject('oi'); sensor = vcGetObject('sensor');
%     sensor = sensorComputeNoiseFree(sensor,oi);
%
%  If you also want to remove the effects of pixel vignetting ... this is
%  normally off, but to make sure you can cal this:
%
%     sensor = sensorSet(sensor,'pixel vignetting',0);
%     sensor = sensorComputeNoiseFree(sensor,oi);
%
%  Other imperfections can be removed by oiSet commands the get rid of lens
%  shading (oiSet(oi,'cos4th','skip');).
%
%     imtool(volts/max(volts(:)));
%
% Web resources:
%    
% See also
% COMPUTATIONAL OVERVIEW:  See sensorCompute
%
% Copyright ImagEval Consultants, LLC, 2009.


%% Define and initialize parameters
if ieNotDefined('sensor'), sensor = vcGet('ISA'); end
if ieNotDefined('oi'),     oi = vcGetObject('oi'); end

% This turns off photon noise and electrical noise.
sensor = sensorSet(sensor,'noise flag',0);

% Other adjustments that make this  noise free.
% No quantization
q      = sensorGet(sensor,'quantization method');
sensor = sensorSet(sensor,'quantization method','analog');

% Analog gain set to unity
ag = sensorGet(sensor,'analog gain');
ao = sensorGet(sensor,'analog offset');
sensor = sensorSet(sensor,'analog gain',1);
sensor = sensorSet(sensor,'analog offset',0);

% Make sure exposure duration is set, no auto-exposure
if sensorGet(sensor,'autoexposure')
    t = autoExposure(oi,sensor);
    sensor = sensorSet(sensor,'exp time',t);
    warning('sensorNF:Exposure','Auto exposure set off, exposure set to %f s',t);
end

% No clipping - we set the voltage swing very high
pixel  = sensorGet(sensor,'pixel');
vSwing = pixelGet(pixel,'voltage swing');
pixel  = pixelSet(pixel,'voltage swing',1e6);
sensor = sensorSet(sensor,'pixel',pixel);

% Compute
sensor = sensorCompute(sensor,oi);

% Restore the parameters so that the ordinary sensorCompute can be run on
% the returned sensor.  The noise free voltage images are in the 'volts'
% field of the sensor.
pixel = pixelSet(pixel,'voltage swing',vSwing);
sensor = sensorSet(sensor,'pixel',pixel);

sensor = sensorSet(sensor,'quantization method',q);

sensor = sensorSet(sensor,'analog gain',ag);
sensor = sensorSet(sensor,'analog offset',ao);

return

