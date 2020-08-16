%% Validation for scenes
%  
% Scripts related to scenes
%
% BW:
% Checked with the new app design implementation.  Runs as of 08.16.2020. 
%

%%
s_sceneDemo;
s_sceneExamples;
s_sceneChangeIlluminant;
s_sceneIncreaseSize
s_sceneFromRGB
s_sceneHCCompress

% Check GUI control
sceneWindow;
scene = ieGetObject('scene');

sceneSet(scene,'gamma',0.5);
sceneSet(scene,'gamma',1);


%% Additional scripts of interest
%
%  s_XYZilluminantTransforms
%  s_sceneReflectanceCharts
%  s_sceneFromRGB
%  scenePlotTest
%
