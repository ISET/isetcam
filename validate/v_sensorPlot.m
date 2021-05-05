%% Script for testing the sensorPlot routine

%%
ieInit

%% Initialize the sensor structure
scene = sceneCreate;
scene = sceneSet(scene,'fov',4);
oi = oiCreate; oi = oiCompute(oi,scene);

%%
sensor = sensorCreate;
sensor = sensorSet(sensor,'qmethod', '10 bit');  % Linear, 10 bits
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

%%
sensorPlot(sensor,'electrons hline',[20 20]);

%%
sensorPlot(sensor,'volts vline',[20 20]);

%%
sensorPlot(sensor,'volts hline',[20 20]);

%%
sensorPlot(sensor,'dv hline',[20 20]);

%%
sensorPlot(sensor,'sensor snr');

%%
uData = sensorPlot(sensor,'electrons hist',[15 15 45 45]);
sensorPlot(sensor,'electrons hist',uData.roiLocs)

%%
sensorPlot(sensor,'pixel snr');
%%
sensorPlot(sensor,'cfa block');

%% Dummy up one of the blocks and check the color
n = sensorGet(sensor,'filter names');
n{3} = 'oDefault';
sensor2 = sensorSet(sensor,'filter names',n);
sensorPlot(sensor2,'cfa block');

%%
sensorPlot(sensor,'cfa full');

%%
sensorPlot(sensor,'etendue');

%%
human = sensorCreate('human');
sensorPlot(human,'cone mosaic');

%% Check setting line color
[~,h] = sensorPlot(human,'color filters');
hline = findobj(h, 'type', 'line');
set(hline(2), 'Color', [1 0.6 0]);

%% Make a multicapture sensor and plot things
sensor = sensorSet(sensor,'exp time',[0.05 0.05]);
sensor = sensorCompute(sensor,oi);
sensorPlot(sensor,'electrons hline',[20 20],'capture',1);

%% These should still work

[uData, g] = sensorPlot(sensor,'cfa full');
[uData,g] = sensorPlot(sensor,'sensor snr');

%%