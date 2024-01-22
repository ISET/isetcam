%% v_icam_humanwvf
%
% Testing the human wvf path
%

%%
scene = sceneCreate('line',384);
scene = sceneSet(scene,'fov',0.5);

oi = oiCreate('human wvf');
oi = oiCompute(oi,scene);
oiWindow(oi);

%%
