%% Change the super pixel in a color sensor
%
% You can experiment with different color filter array patterns.  This
% script illustrates how to change the CFA in a sensor.
%
% See also:  sensorShowCFA, sensorPlot, cameraCreate, cameraWindow
%
% Copyright Imageval Consulting, LLC 2016

%%
ieInit

%% Make a standard oi, sensor and ip
camera = cameraCreate;

% Use a small fov
fov = 8;
pSize = [1.4 1.4]*1e-6;
% Create the scene and calculate with the camera
scene  = sceneCreate('reflectance chart');
scene  = sceneSet(scene,'fov',fov);

camera = cameraSet(camera,'pixel size constant fill factor',pSize);
camera = cameraCompute(camera,scene);

% Show the sensor window
cameraWindow(camera,'sensor');

%% Here are the data transformed by the image processor 
cameraWindow(camera,'ip');

%% Adjust the sensor to a different type
cmySensor = sensorCreate('cmy');
cmySensor = sensorSet(cmySensor,'fov',fov);
cmySensor = sensorSet(cmySensor,'name','cmy');

camera = cameraSet(camera,'sensor',cmySensor);
camera = cameraSet(camera,'pixel size constant fill factor',pSize);
camera = cameraCompute(camera,scene);
cameraWindow(camera,'sensor');

%% Now show the transformed data again 
cameraWindow(camera,'ip');

%% If you would like a different RGB spatial pattern ...
sensor = sensorCreate('RGB');
sensor = sensorSet(sensor,'pattern',[ 2 1 2; 3 2 1; 2 3 2]);
sensor = sensorSet(sensor,'fov',fov);
sensor = sensorSet(sensor,'name','3x3 RGB');
sensor = sensorSet(sensor,'pixel size constant fill factor',pSize);

camera = cameraSet(camera,'sensor',sensor);
camera = cameraCompute(camera,scene);
cameraWindow(camera,'sensor');

%% Now show the transformed data again 
cameraWindow(camera,'ip');

%%  Now a white pixel
rgbwSensor = sensorCreate('rgbw');
rgbwSensor = sensorSet(rgbwSensor,'fov',fov);
rgbwSensor = sensorSet(rgbwSensor,'name','cmy');

camera = cameraSet(camera,'sensor',rgbwSensor);
camera = cameraSet(camera,'pixel size constant fill factor',pSize);
camera = cameraCompute(camera,scene);
cameraWindow(camera,'sensor');

%% Now show the transformed data again 
cameraWindow(camera,'ip');

%%


