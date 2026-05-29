function tests = test_sceneCombine()
tests = functiontests(localfunctions);
end

function testHorizontalCombinePreservesMeanLuminance(~)

scene1 = sceneCreate;
scene2 = sceneCreate;
combinedScene = sceneCombine(scene1,scene2,'direction','horizontal');
meanLuminance = sceneGet(combinedScene,'mean luminance');
referenceLuminance = sceneGet(scene1,'mean luminance');

assert(abs(meanLuminance/referenceLuminance - 1) < 1e-5, ...
    'sceneCombine changed the mean luminance for identical inputs');

assert(isequal(sceneGet(combinedScene,'size'),[64 192]), ...
    'Horizontal sceneCombine returned an unexpected size');
assertRelativeError(sceneGet(combinedScene,'fov'), ...
    sceneGet(scene1,'fov') + sceneGet(scene2,'fov'),1e-12, ...
    'Horizontal sceneCombine returned an unexpected horizontal FOV');
expectedWidth = 2 * sceneGet(scene1,'distance') * ...
    tan(deg2rad(sceneGet(combinedScene,'fov')/2));
assertRelativeError(sceneGet(combinedScene,'width'),expectedWidth,1e-12, ...
    'Horizontal sceneCombine returned a width inconsistent with the stored FOV');

combinedSpacing = sceneGet(combinedScene,'sample spacing');
expectedSpacing = [sceneGet(combinedScene,'height')/sceneGet(combinedScene,'rows'), ...
    sceneGet(combinedScene,'width')/sceneGet(combinedScene,'cols')];
assert(max(abs(combinedSpacing - expectedSpacing)) < 1e-12, ...
    'Horizontal sceneCombine returned a sample spacing inconsistent with its geometry');
expectedHeight = combinedSpacing(1) * sceneGet(combinedScene,'rows');
assertRelativeError(sceneGet(combinedScene,'height'),expectedHeight,1e-12, ...
    'Horizontal sceneCombine returned a height inconsistent with its spacing');

support = sceneGet(combinedScene,'spatial support');
expectedX = [-sceneGet(combinedScene,'width')/2 + combinedSpacing(2)/2, ...
    sceneGet(combinedScene,'width')/2 - combinedSpacing(2)/2];
expectedY = [-sceneGet(combinedScene,'height')/2 + combinedSpacing(1)/2, ...
    sceneGet(combinedScene,'height')/2 - combinedSpacing(1)/2];
assertRelativeError(support(1,1,1),expectedX(1),1e-12, ...
    'Horizontal sceneCombine returned an unexpected left support edge');
assertRelativeError(support(1,end,1),expectedX(2),1e-12, ...
    'Horizontal sceneCombine returned an unexpected right support edge');
assertRelativeError(support(1,1,2),expectedY(1),1e-12, ...
    'Horizontal sceneCombine returned an unexpected top support edge');
assertRelativeError(support(end,1,2),expectedY(2),1e-12, ...
    'Horizontal sceneCombine returned an unexpected bottom support edge');

end

function testVerticalCombinePreservesWidthAndSpacing(~)

scene1 = sceneCreate;
scene2 = sceneCreate;
combinedScene = sceneCombine(scene1,scene2,'direction','vertical');

assert(isequal(sceneGet(combinedScene,'size'),[128 96]), ...
    'Vertical sceneCombine returned an unexpected size');
assertRelativeError(sceneGet(combinedScene,'fov'),sceneGet(scene1,'fov'),1e-12, ...
    'Vertical sceneCombine changed the horizontal FOV');
assertRelativeError(sceneGet(combinedScene,'width'),sceneGet(scene1,'width'),1e-12, ...
    'Vertical sceneCombine changed the scene width');
assertRelativeError(sceneGet(combinedScene,'height'), ...
    sceneGet(scene1,'height') + sceneGet(scene2,'height'),1e-12, ...
    'Vertical sceneCombine returned an unexpected height');

combinedSpacing = sceneGet(combinedScene,'sample spacing');
referenceSpacing = sceneGet(scene1,'sample spacing');
assert(max(abs(combinedSpacing - referenceSpacing)) < 1e-12, ...
    'Vertical sceneCombine changed the sample spacing');

end

function testBothCombineExpandsRowsAndColumns(~)

scene1 = sceneCreate;
scene2 = sceneCreate('freq orient');
scene2 = sceneSet(scene2,'resize',sceneGet(scene1,'size'));
combinedScene = sceneCombine(scene1,scene2,'direction','both');

assert(isequal(sceneGet(combinedScene,'size'),[128 192]), ...
    'Both-direction sceneCombine returned an unexpected size');
assertRelativeError(sceneGet(combinedScene,'fov'),20,1e-12, ...
    'Both-direction sceneCombine returned an unexpected horizontal FOV');
assertRelativeError(sceneGet(combinedScene,'width'), ...
    2 * sceneGet(scene1,'distance') * tan(deg2rad(sceneGet(combinedScene,'fov')/2)), ...
    1e-12, 'Both-direction sceneCombine returned an unexpected width');

sampleSpacing = sceneGet(combinedScene,'sample spacing');
support = sceneGet(combinedScene,'spatial support');
expectedX = [-sceneGet(combinedScene,'width')/2 + sampleSpacing(2)/2, ...
    sceneGet(combinedScene,'width')/2 - sampleSpacing(2)/2];
expectedY = [-sceneGet(combinedScene,'height')/2 + sampleSpacing(1)/2, ...
    sceneGet(combinedScene,'height')/2 - sampleSpacing(1)/2];
assertRelativeError(support(1,1,1),expectedX(1),1e-12, ...
    'Both-direction sceneCombine returned an unexpected left support edge');
assertRelativeError(support(1,end,1),expectedX(2),1e-12, ...
    'Both-direction sceneCombine returned an unexpected right support edge');
assertRelativeError(support(1,1,2),expectedY(1),1e-12, ...
    'Both-direction sceneCombine returned an unexpected top support edge');
assertRelativeError(support(end,1,2),expectedY(2),1e-12, ...
    'Both-direction sceneCombine returned an unexpected bottom support edge');

end

function testCenteredCombineBuildsThreeByThreeLayout(~)

scene1 = sceneCreate;
scene2 = sceneCreate('freq orient');
scene2 = sceneSet(scene2,'resize',sceneGet(scene1,'size'));
combinedScene = sceneCombine(scene1,scene2,'direction','centered');

assert(isequal(sceneGet(combinedScene,'size'),[192 288]), ...
    'Centered sceneCombine returned an unexpected size');
assertRelativeError(sceneGet(combinedScene,'fov'),30,1e-12, ...
    'Centered sceneCombine returned an unexpected horizontal FOV');
assertRelativeError(sceneGet(combinedScene,'width'), ...
    2 * sceneGet(scene1,'distance') * tan(deg2rad(sceneGet(combinedScene,'fov')/2)), ...
    1e-12, 'Centered sceneCombine returned an unexpected width');

sampleSpacing = sceneGet(combinedScene,'sample spacing');
support = sceneGet(combinedScene,'spatial support');
expectedX = [-sceneGet(combinedScene,'width')/2 + sampleSpacing(2)/2, ...
    sceneGet(combinedScene,'width')/2 - sampleSpacing(2)/2];
expectedY = [-sceneGet(combinedScene,'height')/2 + sampleSpacing(1)/2, ...
    sceneGet(combinedScene,'height')/2 - sampleSpacing(1)/2];
assertRelativeError(support(1,1,1),expectedX(1),1e-12, ...
    'Centered sceneCombine returned an unexpected left support edge');
assertRelativeError(support(1,end,1),expectedX(2),1e-12, ...
    'Centered sceneCombine returned an unexpected right support edge');
assertRelativeError(support(1,1,2),expectedY(1),1e-12, ...
    'Centered sceneCombine returned an unexpected top support edge');
assertRelativeError(support(end,1,2),expectedY(2),1e-12, ...
    'Centered sceneCombine returned an unexpected bottom support edge');

end

function assertRelativeError(actual,expected,tolerance,message)

relativeError = abs(actual - expected)/max(abs(expected),eps);
assert(relativeError < tolerance,message);

end