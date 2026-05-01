function tests = test_sensorGainOffset()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
% v_icam_sensorGainOffset
% 
% Test that the gain and offset parameters behave as expected
%
% We correct the voltage for the gain and offset before estimating the
% electrons in sensorGet(sensor,'electrons'))  
%
% Consquently:
%   Changing the gain changes the voltage in the sensor, but it does not
%   change the electron catch. 
%
%   Changing the offset also changes the voltages change, but the mean
%   electron estimate stays the same
%
% Wandell
%

%% Create a uniform field, crop the border
scene = sceneCreate('uniform');
oi = oiCreate;
oi = oiCompute(oi,scene);
oi = oiCrop(oi,'border');

% Make a sensor whose field of view is in the center of the oi
sensor = sensorCreate;
sensor = sensorSet(sensor,'fov',oiGet(oi,'fov')/2,oi);

%% Fix the exposure time
sensor = sensorSet(sensor,'exp time',0.05);

%  Change the gain, and compute the mean.  In ISETCam the gain is a
%  divisor. So a gain of 2 cuts the voltage in half and a gain of 0.5
%  doubles the voltage.
gLevels = [1, 0.5, 2, 4, 8];
meanv = zeros(size(gLevels));  % The voltages should scale
meane = zeros(size(gLevels));  % The electrons should stay the same
for gg = 1:numel(gLevels)
    sensor = sensorSet(sensor,'analog gain',gLevels(gg));
    sensor = sensorCompute(sensor,oi);
    v = sensorGet(sensor,'volts');
    e = sensorGet(sensor,'electrons');
    meane(gg) = mean(e(:));
    meanv(gg) = mean(v(:));
end

%% The voltages should scale
estGain = meanv(1)./meanv;
assert(max(abs(gLevels - estGain)) < 1e-2);

% But the electron count should stay constant
estElectrons = meane(1)./meane;
assert(max(abs(1 - estElectrons)) < 1e-2);

%% Now adjust the offset

sensor = sensorSet(sensor,'analog gain',1);

oLevels = [0 0.05 0.10];
meanv = zeros(size(oLevels));  % The voltages should scale
meane = zeros(size(oLevels));  % The electrons should stay the same

for gg = 1:numel(oLevels)
    sensor = sensorSet(sensor,'analog offset',oLevels(gg));
    sensor = sensorCompute(sensor,oi);
    v = sensorGet(sensor,'volts');
    e = sensorGet(sensor,'electrons');
    meane(gg) = mean(e(:));
    meanv(gg) = mean(v(:));
end

% The estimated number of electrons should go up because we are adding a
% voltage (offset) into the voltage
assert(max(abs(diff(meanv) - 0.05)) < 1e-3);
assert(max(abs(1 - meane/meane(1))) < 1e-2);

%% End

end
