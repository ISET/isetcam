% Convert a PBRT exr into a scene.  Preparing for sceneFromFile

%%
chdir('/Volumes/TOSHIBA EXT/pbrt-v4-scenes-renderings');
fname = 'bistro_boulangerie.exr';
fname = 'sanmiguel/sanmiguel-in-tree.exr';

img = exrread(fname);
imtool(img);

scene = piEXR2ISET(fname);
depthImage = piReadEXR(fname, 'data type','depth');
scene = sceneSet(scene,'depth map',depthImage);
sceneWindow(scene);

% This should work, but doesn't.
% depthmap = piEXR2ISET(fname,'label','depth');

%%
camera = cameraCreate;
camera = cameraSet(camera,'oi',oiCreate);
camera = cameraSet(camera,'sensor',sensorCreate);

sensor = sensorSetSizeToFOV(cameraGet(camera,'sensor'),30);
camera = cameraSet(camera,'sensor',sensor);

camera = cameraCompute(camera,scene);

%%  The imx363 color in the ip for the saturated lights is weird.
% it is ok for the standard sensor.  Something about the IP processing is
% off.
camera = cameraSet(camera,'sensor exp time',0.01);
camera = cameraCompute(camera,'oi');

cameraWindow(camera,'ip');
