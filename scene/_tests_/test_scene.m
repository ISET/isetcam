function tests = test_scene()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% Validation for scenes
%
% Scripts related to scenes
%
% Additional scripts of interest
%
%  s_XYZilluminantTransforms
%  s_sceneReflectanceCharts
%  s_sceneFromRGB
%  scenePlotTest
%

%% Check GUI control

scene = sceneCreate;
sceneWindow(scene);
sceneSet(scene,'gamma',0.5);
sceneSet(scene,'gamma',1);
mn = sceneGet(scene,'mean luminance');

%% Check sceneCombine

scene = sceneCombine(sceneCreate,sceneCreate,'direction','horizontal');
mn2 = sceneGet(scene,'mean luminance');
assert(abs(mn/mn2 - 1) < 1e-5);

% sceneWindow(scene);
% drawnow;

%%


end
