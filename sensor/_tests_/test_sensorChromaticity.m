function tests = test_sensorChromaticity()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% v_sensor
%
%  Scripts to run sensor and pixel functions
%
% Copyright ImagEval Consultants, LLC, 2011.

ieInit;

%% Test chromaticity plot for sensor

scene  = sceneCreate; 
camera = cameraCreate;
camera = cameraCompute(camera,scene);
sensor = cameraGet(camera,'sensor');
% sensorWindow(sensor);

sensorPlot(sensor,'chromaticity',[20 20 40 40]);

%%
drawnow;

%% End
end
