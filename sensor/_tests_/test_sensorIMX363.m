function tests = test_sensorIMX363()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% Testing the IMX363 sensor compute algorithm
%
% I had trouble with this sensor and the autoexposure aeLuminance
% because of the sensorComputeImage command. I adjusted the
% aeLuminance method, but not the others, to make the imx363 work
% properly.  I am not sure why it ever worked.  Perhaps something to
% do with black level that got changed?

%%
ieInit;

%%
scene = sceneCreate('macbeth d65');
oi = oiCreate; oi = oiCompute(oi,scene);

%%
sensor = sensorCreate('imx363');
sensor = sensorSet(sensor,'noise flag',0);

sensor = sensorSet(sensor,'fov',sceneGet(scene,'fov'),oi);
sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor);

%% The mean volts should be the same.
volts = sensorGet(sensor,'volts');
assert(abs( (mean(volts,'all')/0.1193594) - 1) < 1e-5);

%% End

end
