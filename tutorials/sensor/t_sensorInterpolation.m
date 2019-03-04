% Some experiment for sensor

%% init
ieInit;

%% Create a point array 
% inFile = fullfile('/scratch', 'zhenglyu', 'renderedScene', 'landscape', 'landscape4k_scene.mat');
% load(inFile);
scene = sceneCreate('point array');
scene = sceneSet(scene, 'fov', 12);
% sceneWindow(scene);
%%
oi = oiCreate;
oi = oiCompute(oi, scene);
% oiWindow(oi);

%%
% Try to compare the linear model and the gaussian interp model. Will compare
% choose to use the pixel size to be 1, 3, and 5 times the oi
% resolution.
sensor = sensorCreate;

sensor = sensorSet(sensor, 'pixel pdXpos', 0); % Set the X, Y position to be zero
sensor = sensorSet(sensor, 'pixel pdYpos', 0);

pixelSize = 0.1 * oiGet(oi, 'hres');
sensor = sensorSet(sensor, 'pixel size', pixelSize);
sensor = sensorSet(sensor, 'pixel pdwidth', pixelSize);
sensor = sensorSet(sensor, 'pixel pdheight', pixelSize);


sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov'));
sensor = sensorSet(sensor, 'noise flag', -1);
%%
sensorLinear = sensor;
sensorLinear.interp = 'linear';
[sensorLinear1, unitSigCurrent1] = sensorCompute(sensorLinear, oi);
[sensorLinear2, unitSigCurrent2] = sensorCompute(sensorLinear, oi);
% sensorWindow(sensorLinear1);

%%
sensorGaus = sensor;
sensorGaus.interp = 'Gaus';
sensorGaus = sensorCompute(sensorGaus, oi);
% sensorWindow(sensorGaus);

%%
voltsDiff = sensorGet(sensorLinear1, 'volts') - sensorGet(sensorGaus, 'volts');
vcNewGraphWin; imagesc(voltsDiff); colormap('gray'); colorbar; axis off;
vcNewGraphWin; histogram(voltsDiff(:), 'BinLimits', [-1e-3, 1e-3], 'BinWidth', 5e-5);
%%
voltsDiffT = unitSigCurrent1 - unitSigCurrent2;
vcNewGraphWin; imagesc(voltsDiffT); colormap('gray'); colorbar; axis off;
vcNewGraphWin; histogram(voltsDiffT(:), 'BinLimits', [-1e-3, 1e-3], 'BinWidth', 5e-5);
%%
voltsDiffL = sensorGet(sensorLinear1, 'volts') - sensorGet(sensorLinear2, 'volts');
vcNewGraphWin; imagesc(voltsDiffL); colormap('gray'); colorbar; axis off;
vcNewGraphWin; histogram(voltsDiffL(:), 'BinLimits', [-1e-3, 1e-3], 'BinWidth', 5e-5);
%%
ip = ipCreate;
%%
ip = ipCompute(ip, sensorLinear);
ipWindow(ip);
%%
ip = ipCompute(ip, sensorGaus);
ipWindow(ip);