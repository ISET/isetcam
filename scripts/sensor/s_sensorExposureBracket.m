%% Simulate exposure bracketing with sensorCompute
%
% Exposure bracketing acquires a series of exposures. You can simulate
% exposure bracketing by setting the exposure time to be a vector of
% numbers.  The calculation is illustrated here.  You can then visualize
% all of the different exposures in the sensor window, which has a slider
% that lets you scan through the different exposures.
%
% The code first illustrates working with *scene, oi, sensor* directly.
% Then it shows the same calculation using a *camera* object.
%
% See also:  sensorCompute, cameraCreate, cameraWindow
%
% Copyright Imageval, LLC, 2013

%%
ieInit

%% Create a scene, oi, and sensor

% This could be cameraCreate, but for teaching being explicit about the
% objects seems better.
scene  = sceneCreate;
scene  = sceneSet(scene,'fov',4);

oi     = oiCreate;
oi     = oiCompute(scene,oi);
sensor = sensorCreate;

%% Set a range of exposure times

T1 = [0.02 0.04 0.08 0.16 0.32];  % Times
sensor     = sensorSet(sensor,'Exp Time',T1);
nExposures = length(T1);

% Compute all the exposure durations
exposurePlane = floor(nExposures/2) + 1;
sensor = sensorSet(sensor,'exposure plane',exposurePlane);
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor);  

% Notice on the lower right the Bracket, and how there is a slider on the
% lower left that is labeled 'Exposure'. Adjust the slider on the lower
% left of the window to show a different exposure duration.
sensorWindow;

%% Display the shortest exposure

sensor = sensorSet(sensor,'exposure plane',1);
vcReplaceObject(sensor); sensorWindow;

%% Longest
sensor = sensorSet(sensor,'exposure plane',5);
vcReplaceObject(sensor); sensorWindow;

%% This is very short code when you work with a camera object

camera = cameraCreate;
camera = cameraSet(camera,'sensor exp time',T1);
camera = cameraCompute(camera,scene);
cameraWindow(camera,'sensor');

%%