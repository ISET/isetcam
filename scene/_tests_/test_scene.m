function tests = test_scene()
tests = functiontests(localfunctions);
end

function testMain(~)
%% GUI/smoke validation for scenes
%
% This file exercises scene window and smoke-test behavior. The
% quantitative sceneCombine regression lives in test_sceneCombine.
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
sceneGet(scene,'mean luminance');

% sceneWindow(scene);
% drawnow;

%%


end
