%% t_ipDemosaic
%
% Illustrate calls to different demosaicing methods.  Does this with the
% camera method.  Illustrating the actions in the critical image processing
% 'Demosaic'.
%
% Wandell, July, 2019

%%
ieInit

%% If setting ip method by hand, do this
scene = sceneCreate;
oi = oiCreate; sensor = sensorCreate; ip = ipCreate;
oi = oiCompute(oi,scene); sensor = sensorCompute(sensor,oi);
ip = ipSet(ip,'demosaic method','bilinear');
ip = ipCompute(ip,sensor);
ipWindow(ip);

%% Here is the way to do it with the camera object

% This is the Demosaic call from inside of ipCompute (called also by
% cameraCompute). In this illustration, there is no sensor or illuminant
% correction
fprintf('Demosaic method:  %s\n',ipGet(ip,'demosaic method'));

d = Demosaic(ip,sensor);
ieNewGraphWin; imagescRGB(d);

%% Alternative demosaicing method
camera = cameraCreate;
camera = cameraCompute(camera,scene);

camera = cameraSet(camera,'ip demosaic method','adaptive laplacian');
camera = cameraCompute(camera,scene);
cameraWindow(camera,'ip');

%%
camera = cameraSet(camera,'ip demosaic method','laplacian');
camera = cameraCompute(camera,scene);
cameraWindow(camera,'ip');

%%
camera = cameraSet(camera,'ip demosaic method','nearest neighbor');
camera = cameraCompute(camera,scene);
cameraWindow(camera,'ip');

%% A special case for ans RCCC automotive sensor demosaic'd into a monochrome image

sensor = sensorCreate('MT9V024',[],'rccc');
camera = cameraSet(camera,'sensor',sensor);
camera = cameraSet(camera,'ip demosaic method','analog rccc');
camera = cameraCompute(camera,scene);
cameraWindow(camera,'sensor');
cameraWindow(camera,'ip')

%% For monochrome, Demosaic does nothing.

scene = sceneCreate;
sensor = sensorCreate('monochrome');
camera = cameraSet(camera,'sensor',sensor);
camera = cameraCompute(camera,scene);
cameraWindow(camera,'ip')

%%