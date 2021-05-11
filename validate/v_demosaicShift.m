%% v_demosaic

% GG says that there is a shift in the position of the line caused by the
% demosaicking algorithm.  She sent a clear email about this

ieInit

scene = sceneCreate('line ee');

ieAddObject(scene);
sceneWindow;

c = cameraCreate;

c = cameraSet(c, 'ip demosaic method', 'bilinear');
c = cameraCompute(c, scene);
ieAddObject(c);


c = cameraSet(c, 'ip demosaic method', 'Laplacian');
c = cameraCompute(c, scene);
ieAddObject(c.vci);

ipWindow;
