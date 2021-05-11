%% logAR0132AT - ON Semiconductor
%
%  Use the parameters of the AR0132AT, but transform the voltage
%  response by a log10() rather than using linear ADC values.
%
% Copyright Imageval LLC, 2017

%%
ieInit;

%% Parameters from sheet

% RGB Bayer.  RG/GB
% Frame rate 45 Hz (full resolution)

sensorSize = [960, 1280]; % Not important, really, but OK
pixelSize = 3.751e-6; %

% Fill factor

% responsivity = 5.48;  % volts/lux-sec

% MaxSNR = 43.9;        % dB
% MaxDR  = 115;         % dB

% Spectral sensitivities
% Has a multi-exposure mode

%% Test oi

% scene = sceneCreate('sweep frequency',1024,20);
dynamicRange = 2^16;
sz = 256;
% scene = sceneCreate('linear intensity ramp',sz,dynamicRange);

scene = sceneCreate('exponential intensity ramp', sz, dynamicRange);

scene = sceneSet(scene, 'fov', 60);
% ieAddObject(scene); sceneWindow;

oi = oiCreate;
oi = oiSet(oi, 'optics fnumber', 2.8);

oi = oiCompute(oi, scene);
% ieAddObject(oi); oiWindow;

%%
sensor = sensorCreate;
sensor = sensorSet(sensor, 'response type', 'log');

sensor = sensorSet(sensor, 'size', sensorSize);
sensor = sensorSet(sensor, 'pixel size same fill factor', pixelSize);
% We don't think it is backside illuminated.  If it were, we would set the
% photodetector size to be equal to the pixel size using the routine
% pixelCenterFillPD()

colorFilterFile = fullfile(isetRootPath, 'data', 'sensor', 'CMOS', 'ar0132at.mat');

wave = sceneGet(scene, 'wave');
[filterSpectra, filterNames] = ieReadColorFilter(wave, colorFilterFile);
sensor = sensorSet(sensor, 'filter spectra', filterSpectra);
sensor = sensorSet(sensor, 'filter names', filterNames);

sensor = sensorSet(sensor, 'pixel read noise volts', 1e-3);
sensor = sensorSet(sensor, 'pixel voltage swing', 2.8);
sensor = sensorSet(sensor, 'pixel dark voltage', 1e-3);

% Example of well capacity curve as a function of pixel size
% http://www.clarkvision.com/articles/digital.sensor.performance.summary/#full_well
% We set the conversion gain to match the curve for a 4um pixel
sensor = sensorSet(sensor, 'pixel conversion gain', 110e-6);

%%
sensor = sensorSet(sensor, 'exp time', 0.003);

% These values get us close to the numbers we expect from the literature
% snr = pixelSNR(sensor);
% fprintf('Max Pixel SNR is %f\n',max(snr));
% fprintf('Well capacity in electrons %f\n',sensorGet(sensor,'pixel well capacity'));
% sensorGet(sensor,'pixel read noise electrons')

%%
sensor = sensorCompute(sensor, oi);
ieAddObject(sensor);
sensorWindow;
sensorPlot(sensor, 'volts hline', [1, 114]); % (x,y)
sensorPlot(sensor, 'volts hline', [1, 15]); % (x,y)

%%
sensorDR(sensor, 1)

%%
