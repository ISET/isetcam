function tests = test_macbeth
 tests = functiontests(localfunctions);
end

function testIlluminantEstimate(testCase)
ieInit;
scene = sceneCreate;
[~,scene] = chartCornerpoints(scene,true);
ieAddObject(scene);
before = findall(groot,'Type','figure');
estimated = macbethIlluminant(scene,'plot',false);
expected = sceneGet(scene,'illuminant photons');
testCase.verifyEqual(double(estimated),double(expected),'RelTol',1e-6);
testCase.verifyEqual(findall(groot,'Type','figure'),before);
end

function testPlotFalseRequiresCorners(testCase)
scene = sceneCreate;
scene = sceneSet(scene,'chart corner points',[]);
testCase.verifyError(@() macbethIlluminant(scene,'plot',false), ...
    'macbethIlluminant:MissingCorners');
end
