clear; close all;

ieInit;
%% Create Sensor

sensor = sensorCreateIMECSSM4x4vis('rowcol',[300 400]);

%% Create Scene
fov = 40;      % what is this?
%scene  = sceneCreate('reflectance chart');
scene  = sceneCreate('macbeth d65');
scene  = sceneSet(scene,'fov',fov);
sceneWindow(scene);
oi = oiCreate;
oi = oiCompute(oi,scene);

%% Compute optical image
% sensor = sensorSet(sensor,'exposure time',100e-3);
sensor = sensorSet(sensor, 'auto exp', 1);
sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'),oi);
sensor = sensorCompute(sensor,oi);
sensorPlot(sensor,'channels');

%%
sensorChannelImage(sensor);

sensorWindow(sensor);

%%
ip = ipCreate;
ip = ipSet(ip,'render demosaic only',true);
ip = ipCompute(ip,sensor);
data = ipGet(ip,'sensor space');

ieNewGraphWin;
sliceViewer(data);

%%

