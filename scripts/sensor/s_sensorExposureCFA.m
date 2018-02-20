%% Experiments setting exposure separately for each color channel
%
% To control exposure per channel, set exposure times to be a matrix
% matched in size to the sensor cfa pattern.  
%
% See also: 
%
% Copyright Imageval, LLC, 2013

%%
ieInit

%% Create a scene, oi, and sensor

scene  = sceneCreate;
scene  = sceneSet(scene,'fov',4);

oi     = oiCreate;
oi     = oiCompute(scene,oi);
sensor = sensorCreate;
ip     = ipCreate;

%% Set the channel exposures, long for blue

% Array is GR/BG.  Each time (in ms) is exposure duration for a color type.

% Relatively long blue exposure
T1 = [0.04    0.030;
    0.30    0.02];

% Place the exp time
sensor = sensorSet(sensor,'exposure duration',T1);

% Compute
sensor = sensorCompute(sensor,oi);
sensor = sensorSet(sensor,'name','Bluish');
ieAddObject(sensor); sensorWindow('scale',1);

%% Now for a long red exposure

T1 = [0.04    0.70;
    0.0300    0.02];
sensor = sensorSet(sensor,'exposure duration',T1);
sensor = sensorCompute(sensor,oi);
sensor = sensorSet(sensor,'name','Reddish');
ieAddObject(sensor);
sensorWindow('scale',1);

% Click on the CFA exposure button to popup the channel exposure settings

%% Show the image processed result
ip = ipCompute(ip,sensor);

%% The same calculation with a camera objet

camera = cameraCreate;
camera = cameraSet(camera,'sensor exposure duration',T1);
camera = cameraCompute(camera,scene);

cameraWindow(camera,'sensor');

%% 