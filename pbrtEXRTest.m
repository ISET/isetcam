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