%% Change the super pixel color filter array in a color sensor
%
% This script illustrates how to change the CFA in a sensor.
%
% See also:  
%  sensorShowCFA, sensorPlot, cameraCreate, cameraWindow
%

%%
ieInit

%% Make a standard oi, sensor and ip
camera = cameraCreate;

% Use a small fov
fov = 20;
pSize = [1.4 1.4]*1e-6;

%%
% dir(fullfile(isetRootPath,'data','images','rgb'))

% woodDuck.png
[scene, fname] = sceneFromFile('zebra.jpg','rgb', 300, displayCreate);
% Create the scene and calculate with the camera
% scene  = sceneCreate('reflectance chart');
scene  = sceneSet(scene,'fov',fov);

camera = cameraSet(camera,'pixel size constant fill factor',pSize);
camera = cameraCompute(camera,scene);

% Show the sensor window
cameraWindow(camera,'sensor');

%% Here are the data transformed by the image processor
% cameraWindow(camera,'ip');

bayerSensor = sensorCreate;
bayerSensor = sensorSet(bayerSensor,'fov',fov,cameraGet(camera,'oi'));
bayerSensor = sensorSet(bayerSensor,'name','Bayer');

camera = cameraSet(camera,'sensor',bayerSensor);
camera = cameraSet(camera,'pixel size constant fill factor',pSize);
camera = cameraCompute(camera,'oi');
cameraWindow(camera,'sensor');

%% Adjust the sensor to a different type
cmySensor = sensorCreate('ycmy');
cmySensor = sensorSet(cmySensor,'fov',fov,cameraGet(camera,'oi'));
cmySensor = sensorSet(cmySensor,'name','cmy');

camera = cameraSet(camera,'sensor',cmySensor);
camera = cameraSet(camera,'pixel size constant fill factor',pSize);
camera = cameraCompute(camera,'oi');
cameraWindow(camera,'sensor');

%% Now show the transformed data again
% cameraWindow(camera,'ip');

%% If you would like a different RGB spatial pattern ...
sensor = sensorCreate('RGB');

% Notice that we have gone from a 2x2 super pixel to a 3x3.  So we adjust
% the pattern and the sensor size.
sensor = sensorSet(sensor,'pattern and size',[ 2 1 2; 3 2 1; 2 3 2]);
sensor = sensorSet(sensor,'fov',fov,cameraGet(camera,'oi'));
sensor = sensorSet(sensor,'name','3x3 RGB');
sensor = sensorSet(sensor,'pixel size constant fill factor',pSize);

camera = cameraSet(camera,'sensor',sensor);
camera = cameraCompute(camera,'oi');
cameraWindow(camera,'sensor');

%% Now show the transformed data again
% cameraWindow(camera,'ip');

%%  Now a white pixel
rgbwSensor = sensorCreate('rgbw');
rgbwSensor = sensorSet(rgbwSensor,'fov',fov,cameraGet(camera,'oi'));
rgbwSensor = sensorSet(rgbwSensor,'name','rgbw');

camera = cameraSet(camera,'sensor',rgbwSensor);
camera = cameraSet(camera,'pixel size constant fill factor',pSize);
camera = cameraCompute(camera,'oi');
cameraWindow(camera,'sensor');

%% Now show the transformed data again
% camera Window(camera,'ip');

%%

%%  Now a quad sensor

quadSensor = sensorCreate;
% Should be sensorCreateQuad;
quadSensor = sensorSet(quadSensor,'pattern',[3 3 2 2; 3 3 2 2; 2 2 1 1; 2 2 1 1]);
quadSensor = sensorSet(quadSensor,'fov',fov,oi);
quadSensor = sensorSet(quadSensor,'name','quad');

camera = cameraSet(camera,'sensor',quadSensor);
camera = cameraSet(camera,'pixel size constant fill factor',pSize);
camera = cameraCompute(camera,scene);
cameraWindow(camera,'sensor');

img = cameraGet(camera, 'sensor rgb');
ieViewer(img);

%% END