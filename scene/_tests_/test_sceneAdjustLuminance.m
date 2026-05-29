function tests = test_sceneAdjustLuminance()
tests = functiontests(localfunctions);
end

function testSceneAdjustLuminanceModes(~)
%% Focused checks for sceneAdjustLuminance

ieInit;

tolerance = 1e-4;
roi = [9 9 24 24];

verifyAdjustment('mean', 55, tolerance);
verifyAdjustment('max', 175, tolerance);
verifyAdjustment('median', 80, tolerance);
verifyAdjustment('roi', 120, tolerance, roi);

end

function verifyAdjustment(method, targetL, tolerance, roi)

baselineScene = sceneCreate;
scene = baselineScene;

oldMeanPhoton = mean(sceneGet(scene, 'photons'), 'all');
oldMeanIlluminant = mean(sceneGet(scene, 'illuminant photons'), 'all');

switch method
    case 'mean'
        scene = sceneAdjustLuminance(scene, method, targetL);
        measuredL = sceneGet(scene, 'mean luminance');
    case {'max', 'median'}
        scene = sceneAdjustLuminance(scene, method, targetL);
        measuredL = sceneGet(scene, sprintf('%s luminance', method));
    case 'roi'
        scene = sceneAdjustLuminance(scene, method, targetL, roi);
        measuredL = sceneGet(scene, 'roi mean luminance', roi);
    otherwise
        error('Unknown test method %s', method);
end

newMeanPhoton = mean(sceneGet(scene, 'photons'), 'all');
newMeanIlluminant = mean(sceneGet(scene, 'illuminant photons'), 'all');

assert(abs(measuredL - targetL) < tolerance * targetL, ...
    sprintf('sceneAdjustLuminance failed for %s mode.', method));
assert(abs((newMeanPhoton / oldMeanPhoton) - (newMeanIlluminant / oldMeanIlluminant)) < tolerance, ...
    sprintf('Photon and illuminant scaling diverged for %s mode.', method));

if nargin > 4
    oldReflectance = sceneGet(baselineScene, 'roi mean photons', roi) ./ sceneGet(baselineScene, 'roi mean illuminant photons', roi);
    newReflectance = sceneGet(scene, 'roi mean photons', roi) ./ sceneGet(scene, 'roi mean illuminant photons', roi);
    assert(max(abs(oldReflectance - newReflectance)) < 1e-6, ...
        'ROI reflectance should be preserved after luminance adjustment.');
end

end