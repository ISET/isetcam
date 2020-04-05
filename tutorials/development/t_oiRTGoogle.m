%% Tutorial for ray tracing optics image calculation using ggl lens

%% Init
ieInit;

%%
scene = sceneCreate('slanted bar',512);

scene = sceneSet(scene, 'distance', 0.6);
rect = [200, 200, 100, 100];
scene = sceneCrop(scene, rect);

%% Calculate horizontal FOV set to scene
% Given (1) sensor pixel size and (2) size of the scene representation
% image, what is the horizontal FOV that should be set to scene
pixelSize = 1.21e-6; % 1.2 um for sensor pixel
optics = load('lensmatfile.mat', 'optics');
optics = optics.optics;

focalLength = optics.rayTrace.effectiveFocalLength * 1e-3; % Convert to m

% Get the size of scene
sz = sceneGet(scene, 'size');
height = pixelSize *sz(1);
width = pixelSize * sz(2);


hfov = 2 * atand(width/(2*focalLength) ); % Scene hFOV
scene = sceneSet(scene, 'fov', hfov);
% sceneWindow(scene)
%%
dFov = sceneGet(scene, 'diagonal angular');
optics = opticsSet(optics, 'rtfov', max(opticsGet(optics, 'rtfov'), dFov));

oi = oiCreate('ray trace');
oi = oiSet(oi, 'optics', optics);
oi = oiSet(oi, 'optics model', 'ray trace'); % Is this necessary?
oi = oiCompute(oi, scene);

%%