function tests = test_sensorSize()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% v_sensorSize
%
% Test adjusting the sensor field of view and size.
%
% See also
%   v_sensor*

%% Original
scene = sceneCreate;
oi = oiCreate;
oi = oiCompute(oi,scene);
sensor = sensorCreate;
sensor = sensorCompute(sensor,oi);

sensorWindow(sensor);

%% Set by field of view
sensor2 = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'),oi);
sensor2 = sensorCompute(sensor2,oi);
sensorWindow(sensor2);

%% Increase the size this way

sz = sensorGet(sensor2,'size');
sensor3 = sensorSet(sensor,'size',sz);
sensor3 = sensorCompute(sensor3,oi);
sensorWindow(sensor3);

%%
drawnow;

%%




end
