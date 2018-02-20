%% v_drawShape
%
% Validates the function ieDrawShape, which puts simple shapes for ROIs on
% the different object windows.
%
% Shows how to draw regions of interest on top of the different object
% windows.
%
% Copyright Imageval Consulting, LLC 2015

ieInit

%% Scene
scene = sceneCreate; ieAddObject(scene); sceneWindow;
h = ieDrawShape(scene,'rectangle',[10 10 50 50]);
pause(1); delete(h);

%% Optical image
oi = oiCreate;
oi = oiCompute(oi,scene); ieAddObject(oi); oiWindow;
h = ieDrawShape(oi,'rectangle',[10 10 50 50]);
pause(1); delete(h);

%% Sensor
sensor = sensorCreate;
sensor = sensorCompute(sensor,oi);ieAddObject(sensor); sensorWindow;
h = ieDrawShape(sensor,'rectangle',[10 10 50 50]);
pause(1); delete(h);

%% Image processing
ip = ipCreate;
ip = ipCompute(ip,sensor);ieAddObject(ip); ipWindow;
h = ieDrawShape(ip,'rectangle',[10 10 50 50]);
pause(1); delete(h);

% This parameter doesn't exist for the other objects yet.  So just tested
% here.
c = ipGet(ip,'center');
radius = c(1)/4;
h = ieDrawShape(ip,'circle',c(1:2),radius);
set(h,'color',[0 0 1]);
pause(1);
delete(h);

%% END


