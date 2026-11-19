function tests = test_scene
 tests = functiontests(localfunctions);
end

function testDefaultRadiance(testCase)
% Golden values for the default D65 Macbeth chart, without a scene window.
scene = sceneCreate;
photons = double(sceneGet(scene,'photons'));
testCase.verifyEqual(sceneGet(scene,'mean luminance'),100,'AbsTol',1e-6);
testCase.verifyEqual(max(photons(:)),1.3119e16,'RelTol',1e-5);
testCase.verifyEqual(mean(photons(:)),3.7624e15,'RelTol',1e-5);
end
