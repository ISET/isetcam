function [DR, maxVoltage, minVoltage] = sensorDR(sensor, integrationTime)
%Compute sensor dynamic range (in dB)
%
%   [DR, maxVoltage, minVoltage] = sensorDR(sensor,integrationTime)
%
%  This algorithm calculates the ratio of the maximum pixel current divided
%  by the minimum voltage.
%
%      DR = 20 * log10(maxVoltage ./ minVoltage);
%
%  The maximum voltage is determined by the voltage swing minus the
%  darkvoltage.
%
%  The minimum voltage depends on the noise, sqrt(dkVariance + rnVariance +
%  offsetSD.^2);    Noise is measured in electrons, because these noise
%  terms are Poisson in electrons (but not in volts).
%
%  The noise is calculated as if we randomly pick a single pixel from the
%  image sensor array.  For this model, the single pixel has the noise
%  inherent in the pixel and the noise inherent in the variation across the
%  sensor array. In this model the sensor DR is smaller than the pixel DR.
%
%  Another possible sensorDR model is to assume that we are averaging
%  across some number of pixels.  In that case, the noise will go down
%  because the spatial averaging will reduce the total noise.  This model,
%  not calculated here, results in a sensor DR that exceeds the pixel DR
%  (unless DSNU is very high).
%
%  If no integrationTime is specified, the integration time from the sensor
%  in the argument to the function is used.  If no sensor is specified in
%  the calling routine, the currently selected sensor is used.
%
%  If the sensor is set to auto-exposure or 0 integration time, an empty DR
%  value is returned.
%
%  If we are using bracketed or CFA exposures the minimum and maximum DR
%  values are returned; these correspond to the shortest and longest
%  exposure times.
%
% Example:
%    sensor = vcGetObject('sensor');
%    DR     = sensorDR(sensor,0.10)
%    [DR, maxV, minV] = sensorDR(sensor);
%
% Copyright ImagEval Consultants, LLC, 2005

q = vcConstants('q');

if ieNotDefined('sensor'), [val, sensor] = vcGetSelectedObject('sensor'); end
if ieNotDefined('integrationTime'), integrationTime = sensorGet(sensor, 'integrationTime'); end

if integrationTime == 0
    DR = [];
    return;
else
    integrationTime = sort(integrationTime(:));
    if length(integrationTime(:)) > 1
        integrationTime = [integrationTime(1), integrationTime(end)];
    end
end

pixel = sensorGet(sensor, 'pixel');

% Define noise variables used to set minimum response level
darkVoltage = pixelGet(pixel, 'darkvolt'); % V/s
sigmaRead = pixelGet(pixel, 'readNoiseVolts'); % V
cGain = pixelGet(pixel, 'conversionGain'); % V/e-

% Shotnoise due to dark current
% The dark noise is Poisson when expressed in electrons.
% We convert the dark voltage to electrons
dkElectrons = (darkVoltage * integrationTime) / cGain; % Electrons

% The variance of the dark electrons is also dkElectrons, but the units for
% variance are electrons squared.  To convert these back to volts^2, we
% need to multiply by the conversion gain squared
dkVariance = dkElectrons * (cGain^2); % V^2

% Read noise
rnVariance = sigmaRead^2; % V^2

% Offset FPN or dsnu
offsetVariance = sensorGet(sensor, 'offsetsd')^2; % V^2

% Add all the variances up to get the noise standard devaiton
noiseSD = sqrt(dkVariance+rnVariance+offsetVariance); % e-

% Heart of the calculation -
% The max voltage is the voltage swing minus the dark voltage
% The noise standard deviation in volts is noiseSD
maxVoltage = pixelGet(sensor.pixel, 'voltageswing') - (darkVoltage * integrationTime);
minVoltage = noiseSD;

% Some special cases have no noise, so we have infinite DR.  But that is
% not realistic, just used in some ideal cases.  We protect against an
% error here.
if minVoltage == 0, DR = Inf;
else DR = 20 * log10(maxVoltage./minVoltage);
end

return;
