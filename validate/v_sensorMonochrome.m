%% v_sensorMonochrome
%
% Test whether we can build and show data from a monochrome sensor
%
% Copyright Imageval Consulting, LLC 2015

ieInit

%% Build on oi
s = sceneCreate;
oi = oiCreate;
oi = oiCompute(oi, s);

%%
sensor = sensorCreate('monochrome');
sensor = sensorCompute(sensor, oi);
sensorWindow(sensor);

%%
ip = ipCreate;
ip = ipCompute(ip, sensor);
ieAddObject(ip);
ipWindow;

%%
sensor = sensorCreate;
sensor = sensorCompute(sensor, oi);
sensorWindow(sensor);

ip = ipCompute(ip, sensor);
ieAddObject(ip);
ipWindow;

%% END
