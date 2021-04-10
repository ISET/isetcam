%% Spatial resample of a scene and and oi
%
% Validate the spatial resampling of the scene and oi photon data.
%
% Copyright Imageval Consulting, LLC 2016

%%
ieInit

%% Create a scene
scene = sceneCreate; 
scene = sceneSet(scene,'fov',1);
sceneWindow(scene);
pause(0.2);

%% Resample
dx = 50;
scene = sceneSpatialResample(scene,dx,'um');
sceneWindow(scene);

sr = sceneGet(scene,'spatial resolution','um');
assert(abs(sr(2) - 50) < 0.05)
pause(0.2);

%% Create an oi with a larger spatial sample (14 um)
scene = sceneCreate; 
scene = sceneSet(scene,'fov',20);

oi = oiCreate;
oi = oiCompute(oi,scene);
oiWindow(oi);
pause(0.2);

%% Now sample at 2 um
dx = 2;
oi = oiSpatialResample(oi,dx,'um');

oiWindow(oi);
sr = oiGet(oi,'spatial resolution','um');
assert(abs(sr(2) - 2) < 0.05)

%% 