% v_sensorResize
%
% Test resizing the sensor.  Mostly tested with human here.
%
% v_sensorResize
%
% See also
%   v_sensorSize (should be merged; that one tests with camera)

%%
ieInit

%% Create a scene and compute an OI
scene = sceneCreate;
sceneWindow(scene);

oi = oiCreate;
oi = oiCompute(scene,oi);

%% Let the resizing tests begin

sensor = sensorCreate('human');
sensor = sensorSet(sensor,'exptime',0.2);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

%% Something funny happens with the exposure duration.
rows = [10,10]; cols = [10,10];
sensor2 = sensorHumanResize(sensor,rows,cols);
sensor2 = sensorSet(sensor2,'exptime',0.2);
sensor2 = sensorCompute(sensor2,oi);
sensorWindow(sensor2);

%%
rows = [-10,-10]; cols = [-10,-10];
sensor3 = sensorHumanResize(sensor2,rows,cols);
sensor3 = sensorSet(sensor3,'exptime',0.2);
sensor3 = sensorCompute(sensor3,oi);

%%
rows = [50,0]; cols = [0,0];
sensor4 = sensorHumanResize(sensor,rows,cols);
sensor4 = sensorSet(sensor4,'exptime',0.2);
sensor4 = sensorCompute(sensor4,oi);
v = sensorGet(sensor4,'volts');
imagesc(v)
sensorWindow(sensor4);

%%
rows = [-50,0]; cols = [0,0];
sensor5 = sensorHumanResize(sensor4,rows,cols);
sensor5 = sensorSet(sensor5,'volts',v(51:end,:));
% vcNewGraphWin; v2 = sensorGet(sensor5,'volts'); imagesc(v2)
sensorWindow(sensor5);

%% END


