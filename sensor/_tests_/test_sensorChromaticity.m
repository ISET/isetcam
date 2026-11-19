function tests = test_sensorChromaticity
 tests = functiontests(localfunctions);
end

function testChromaticity(testCase)
ieInit;
scene = sceneCreate;
camera = cameraCompute(cameraCreate,scene);
sensor = cameraGet(camera,'sensor');
rect = [20 20 40 40];
rg = sensorGet(sensor,'chromaticity',rect);
testCase.verifySize(rg,[1600 2]);
testCase.verifyTrue(all(isfinite(rg(:))));
testCase.verifyGreaterThanOrEqual(rg,0);
testCase.verifyLessThanOrEqual(sum(rg,2),1+1e-12);
end
