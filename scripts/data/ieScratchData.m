%% Create some scratch data for testing
%
% Sometimes you just want to try something and you need a scene, oi, sensor
% and image processor.  We create some simple defaults in the work space by
% this script.
%
% By default, they are not added to the database or breought up in a
% window.  They are just created in the work space.
%
% Imageval Consulting, LLC, 2016

%%  Not sure if we should initialize
ieInit

%% Slanted bar scene and oi

scene = sceneCreate('slanted bar');
oi = oiCreate;
oi = oiCompute(oi, scene);
% ieAddObject(oi); oiWindow;

%% Bayer sensor

sensor = sensorCreate;
sensor = sensorCompute(sensor, oi);
% ieAddObject(sensor); sensorWindow;

%% Standard image processor

ip = ipCreate;
ip = ipCompute(ip, sensor);

% ieAddObject(ip); ipWindow;

%% Announce

disp('These variables were initialized')
whos

%%