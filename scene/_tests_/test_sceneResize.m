function tests = test_sceneResize()
tests = functiontests(localfunctions);
end

function testResizePreservesWidthFOVAndMeanLuminance(~)

ieInit;

scene = sceneCreate('checkerboard',16,8,'ep');
originalFOV = sceneGet(scene,'fov');
originalWidth = sceneGet(scene,'width');
originalMeanL = sceneGet(scene,'mean luminance');

resizedScene = sceneSet(scene,'resize',[96 144]);

assert(isequal(sceneGet(resizedScene,'size'),[96 144]), ...
    'scene resize returned an unexpected size');
assertRelativeError(sceneGet(resizedScene,'fov'),originalFOV,1e-12, ...
    'scene resize changed the horizontal FOV');
assertRelativeError(sceneGet(resizedScene,'width'),originalWidth,1e-12, ...
    'scene resize changed the scene width');
assertRelativeError(sceneGet(resizedScene,'mean luminance'),originalMeanL,1e-6, ...
    'scene resize changed the mean luminance');

sampleSpacing = sceneGet(resizedScene,'sample spacing');
assert(max(abs(sampleSpacing - [sceneGet(resizedScene,'height')/96, originalWidth/144])) < 1e-12, ...
    'scene resize returned an unexpected sample spacing');

support = sceneGet(resizedScene,'spatial support');
expectedX = [-sceneGet(resizedScene,'width')/2 + sampleSpacing(2)/2, ...
    sceneGet(resizedScene,'width')/2 - sampleSpacing(2)/2];
expectedY = [-sceneGet(resizedScene,'height')/2 + sampleSpacing(1)/2, ...
    sceneGet(resizedScene,'height')/2 - sampleSpacing(1)/2];
assertRelativeError(support(1,1,1),expectedX(1),1e-12, ...
    'scene resize returned an unexpected left support edge');
assertRelativeError(support(1,end,1),expectedX(2),1e-12, ...
    'scene resize returned an unexpected right support edge');
assertRelativeError(support(1,1,2),expectedY(1),1e-12, ...
    'scene resize returned an unexpected top support edge');
assertRelativeError(support(end,1,2),expectedY(2),1e-12, ...
    'scene resize returned an unexpected bottom support edge');

end

function assertRelativeError(actual,expected,tolerance,message)

relativeError = abs(actual - expected)/max(abs(expected),eps);
assert(relativeError < tolerance,message);

end