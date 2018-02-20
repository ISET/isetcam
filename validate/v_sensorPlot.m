%% Script for testing the sensorPlot routine

%% 
ieInit

%% Initialize the sensor structure
scene = sceneCreate; 
scene = sceneSet(scene,'fov',4);
oi = oiCreate; oi = oiCompute(oi,scene);

sensor = sensorCreate; 
sensor = sensorSet(sensor,'qmethod', '10 bit');  % Linear, 10 bits
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor);
sensorWindow('scale',1');

%%
sensorPlot(sensor,'electrons hline',[20 20]);

%%
[uData, g] = sensorPlot(sensor,'volts vline',[20 20]);

%%
[uData, g] = sensorPlot(sensor,'volts hline',[20 20]);

%%
[uData, g] = sensorPlot(sensor,'dv hline',[20 20]);

%%
[uData,g] = sensorPlot(sensor,'sensor snr');

%% 
uData = sensorPlot(sensor,'electrons hist',[15 15 45 45]);
sensorPlot(sensor,'electrons hist',uData.roiLocs)

%%
uData = sensorPlot(sensor,'pixel snr');
%%
[uData, g] = sensorPlot(sensor,'cfa block');

%% Dummy up one of the blocks and check the color
n = sensorGet(sensor,'filter names');
n{3} = 'oDefault';
sensor2 = sensorSet(sensor,'filter names',n);
[uData, g] = sensorPlot(sensor2,'cfa block');

%%
[uData, g] = sensorPlot(sensor,'cfa full');

%%
[uData, g] = sensorPlot(sensor,'etendue');

%%
human = sensorCreate('human');
[uData, g] = sensorPlot(human,'cone mosaic');

%% Check setting line color
[~,h] = sensorPlot(human,'color filters');
hline = findobj(h, 'type', 'line');
set(hline(2), 'Color', [1 0.6 0]);

%%


