function sensor = sensorComputeMEV(sensor, oi, varargin)
% Compute with multiple exposure values and return combined response
%
% Syntax
%    sensor = sensorComputeMEV(sensor, oi, varargin)
%
% Brief description
%    The sensor struct has multiple exposure times set.  The returned
%    sensor data are then recombined into a single value using a
%    reconstruction algorithm.
%
% Inputs
%   sensor:
%   oi:
%
% Optional key/value pairs
%   N/A
%
% Returns
%   sensor: The modified sensor with a single exposure containing the
%           combined values.  The maximum voltage is adjusted to allow for
%           the fact that there were multiple exposure values.
%
% Wandell, 2019
%
% See also
%   sensorCompute
%

% Examples:
%{
scene = sceneFromFile('Feng_Office-hdrs.mat','multispectral');
oi = oiCreate; oi = oiCompute(oi,scene);
sensor = sensorCreate;
sensor = sensorSet(sensor,'fov',sceneGet(scene,'fov'));

maxTime  = 0.2;   % seconds
expTimes = [maxTime/10, maxTime];
sensor   = sensorSet(sensor,'exp time',expTimes);

sensorMEV = sensorComputeMEV(sensor,oi);
sensorMEV = sensorSet(sensorMEV,'name','Multiple exposure');
sensorWindow(sensorMEV);
%}

%%

% Some day we will add parser
% p = inputParser;

%% Compute with multiple exposure times

sensor    = sensorCompute(sensor,oi);

%% Reconstruct

volts = sensorGet(sensor, 'volts');
vSwing = sensorGet(sensor, 'pixel voltage swing');
nExposures = sensorGet(sensor, 'n exposures');
expTimes = sensorGet(sensor, 'exp time');
maxTime = max(expTimes(:));

% Start out with the volts from the longest exposure time
combinedV = volts(:, :, end);

% Find the saturated pixels and replace them with estimates from
% shorter durations.  These may be saturated, too.  So, we loop down until
% there are no saturated pixels
thisExp = 1;
maxV = vSwing * 0.95;
for thisExposure = (nExposures - 1):-1:1
    % Find the saturated pixels for this level
    lst = (combinedV > maxV);
    % fprintf('Exposure %d.  Replacing %d pixels\n',thisExposure,sum(lst(:)));
    if sum(lst(:)) == 0, break
    else
        % Scaled volts for the shorter duration.
        sFactor = (maxTime / expTimes(thisExposure));
        theseV = volts(:, :, thisExposure) * sFactor;
        combinedV(lst) = theseV(lst);
        maxV = maxV * sFactor;
        thisExp = thisExp + 1;
    end
end

%% Put the data back into the sensor

sensor = sensorSet(sensor, 'pixel voltage swing', max(combinedV(:))/0.95);
sensor = sensorSet(sensor, 'volts', combinedV);
sensor = sensorSet(sensor, 'name', 'combined');

% Not sure what I should put in here.
sensor = sensorSet(sensor, 'exp time', maxTime);

end
