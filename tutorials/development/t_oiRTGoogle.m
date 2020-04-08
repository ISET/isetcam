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
load('lensmatfile.mat', 'optics');

oi = oiCreate('ray trace');
oi = oiSet(oi, 'optics', optics);

focalLength = oiGet(oi, 'optics rteffectivefocallength', 'm'); % In meters

nPixels = 1000;
% This is the width of the sensor in meters
width = pixelSize * nPixels;

hfov = 2 * atand(width/(2*focalLength) ); % Scene hFOV
scene = sceneSet(scene, 'fov', hfov);

% sceneWindow(scene)
%%
oi = oiCompute(oi, scene);

%%