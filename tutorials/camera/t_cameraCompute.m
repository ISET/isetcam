%% s_cameraCompute
%
% Illustrate camera creation and computation
%
% Copyright Imageval, LLC 2014


%%
ieInit

%% Illustrate use of camera structure

scene = sceneCreate;
camera = cameraCreate('default');
camera = cameraCompute(camera,scene);
cameraWindow(camera,'ip');

cameraWindow(camera,'sensor');


%%