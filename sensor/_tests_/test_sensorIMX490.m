function tests = test_sensorIMX490()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% Testing the IMX490 sensor compute algorithm
%
% I had trouble with the IMX363 sensor and the autoexposure
% aeLuminance.  See comments in autoExposure and v_icam_sensorimx363.

%%
ieInit;

%%
scene = sceneCreate('macbeth d65');
oi = oiCreate; oi = oiCompute(oi,scene);

%%
sensor = sensorCreate('imx490-large');
sensor = sensorSet(sensor,'noise flag',0);

sensor = sensorSet(sensor,'fov',sceneGet(scene,'fov'),oi);
sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor);

%% The mean volts should be the same.
volts = sensorGet(sensor,'volts');
assert(abs( (mean(volts,'all')/0.2167) - 1) < 1e-3);

%%
sensor = sensorCreate('imx490-small');
sensor = sensorSet(sensor,'noise flag',0);

sensor = sensorSet(sensor,'fov',sceneGet(scene,'fov'),oi);
sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor);

%% The mean volts should be the same.
volts = sensorGet(sensor,'volts');
assert(abs( (mean(volts,'all')/0.2167) - 1) < 1e-3);

%% End

end
