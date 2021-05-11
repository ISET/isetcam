%% These are for the ON/Aptina sensor MT9V024
%
% Apparently ON bought Aptina.  ON is headquartered in Shenzhen.  You still
% sometimes see these listed as Aptina sensors.
%
% There are three types of color filters stored at the top here: Red/Clear,
% RGB, and Mono.  These are put in data/sensors/colorfilters/auto
%
% The second half of the file builds the sensors.  Some of the specs are
% taken from the data sheet below.  We should keep trying to improve the
% accuracy of these values.  These differ from the ARXXX version because
% the pixels are 6 microns, and that model has 3.75 micron pixels.
%
% Reference:
%  JEF stored PDFs defining several of the properties of these ON sensors
%  on our Google Drive, SCIEN, Papers, 2017 Vehicle Evaluation folder.
%  This script reads in the spectral response curves of the sensors and
%  sets some sof the other features so we can use them in simulation.
%
% Online references
%  http://www.viewrun.co.kr/files/mt9v024513.pdf
%  http://www.onsemi.com/pub/Collateral/MT9V024-D.PDF
%
% Wandell, SCIEN

%%
ieInit;

%% Mono

chdir(fullfile(isetRootPath, 'data', 'sensor', 'colorfilters', 'auto', 'ON', 'MONO'));
load('Mono.mat', 'Mono')

wave = 380:10:1080;
W = interp1(Mono(:, 1), Mono(:, 2), wave, 'linear', 'extrap');
W = W / 100;

vcNewGraphWin;
plot(wave, W, 'k-');
grid on; xlabel('Wavelength (nm)'); ylabel('Responsivity')

%%  Save the color filters

Mono = W(:);
cf.wavelength = wave;
cf.data = Mono;
cf.filterNames = {'w'};
cf.comment = 'Grabit from ON data sheet MT9V024-D.PDF in SCIEN 2017 Vehicle folder';
ieSaveColorFilter(cf, fullfile(isetRootPath, 'data', 'sensor', 'colorfilters', 'auto', 'MT9V024_Mono.mat'));

%%  Check that we can read and plot the filters

testWave = 400:5:780;
[data, filterNames] = ieReadColorFilter(testWave, 'MT9V024_Mono.mat');
vcNewGraphWin;
plot(testWave, data, 'k-');
grid on; xlabel('Wavelength (nm)'); ylabel('Responsivity')
filterNames

%% The RGB

chdir(fullfile(isetRootPath, 'data', 'sensor', 'colorfilters', 'auto', 'ON', 'RGB'));
load('redChannel.mat', 'RedChannel')
load('greenChannel.mat', 'GreenChannel')
load('blueChannel.mat', 'BlueChannel')

R = interp1(RedChannel(:, 1), RedChannel(:, 2), wave, 'linear', 'extrap');
R = R / 100;

G = interp1(GreenChannel(:, 1), GreenChannel(:, 2), wave, 'linear', 'extrap');
G = G / 100;

B = interp1(BlueChannel(:, 1), BlueChannel(:, 2), wave, 'linear', 'extrap');
B = B / 100;

vcNewGraphWin;
plot(wave, R, 'r-', wave, G, 'g-', wave, B, 'b-');
grid on; xlabel('Wavelength (nm)'); ylabel('Responsivity')

%% Save the RGB filters

RGB = [R(:), G(:), B(:)];
cf.wavelength = wave;
cf.data = RGB;
cf.filterNames = {'r', 'g', 'b'};
cf.comment = 'Grabit from data sheet MT9V024-D.PDF in SCIEN 2017 Vehicle folder';
ieSaveColorFilter(cf, fullfile(isetRootPath, 'data', 'sensor', 'colorfilters', 'auto', 'MT9V024_RGB.mat'));

%%  Check that we can read and plot the filters

testWave = 400:5:950;
[data, filterNames] = ieReadColorFilter(testWave, 'MT9V024_RGB.mat');
vcNewGraphWin;
plot(testWave, data, '-');
grid on; xlabel('Wavelength (nm)'); ylabel('Responsivity')
filterNames

%% RCCC image sensor

chdir(fullfile(isetRootPath, 'data', 'sensor', 'colorfilters', 'auto', 'ON', 'RCCC'));

load('r_RCCC.mat', 'r_RCCC')
R = interp1(r_RCCC(:, 1), r_RCCC(:, 2), wave, 'linear', 'extrap');
R = R / 100;

load('c_RCCC.mat', 'c_RCCC')
C = interp1(c_RCCC(:, 1), c_RCCC(:, 2), wave, 'linear', 'extrap');
C = C / 100;

vcNewGraphWin;
plot(wave, C, 'k-', wave, R, 'r-');
grid on; xlabel('Wavelength (nm)'); ylabel('Responsivity')

%% Save the RCCC filters

cf.wavelength = wave;
cf.data = [R(:), C(:)];
cf.filterNames = {'r', 'w'};
cf.comment = 'Grabit from ON data sheet MT9V024-D.PDF in SCIEN 2017 Vehicle folder';
ieSaveColorFilter(cf, fullfile(isetRootPath, 'data', 'sensor', 'colorfilters', 'auto', 'MT9V024_RCCC.mat'));

%%  Check that we can read and plot the filters

testWave = 400:5:950;
[data, filterNames] = ieReadColorFilter(testWave, 'MT9V024_RCCC.mat');
vcNewGraphWin;
plot(testWave, data, '-');
grid on; xlabel('Wavelength (nm)'); ylabel('Responsivity')
filterNames

%% Make an RGBW format color filter set

[W, wName, wFileData] = ieReadColorFilter([], 'MT9V024_RCCC.mat');
[RGB, rgbNames, rgbFileData] = ieReadColorFilter([], 'MT9V024_RGB.mat');
cf.wavelength = wFileData.wavelength;
cf.data = [rgbFileData.data, wFileData.data(:, 2)];
cf.filterNames = {rgbNames{:}, wName{2}};
cf.comment = 'Combined from MT9V024 RGB and RC data';
ieSaveColorFilter(cf, fullfile(isetRootPath, 'data', 'sensor', 'colorfilters', 'auto', 'MT9V024_RGBW.mat'));

%%
testWave = 400:5:950;
[data, filterNames] = ieReadColorFilter(testWave, 'MT9V024_RGBW.mat');
vcNewGraphWin;
plot(testWave, data, '-');
grid on; xlabel('Wavelength (nm)'); ylabel('Responsivity')
filterNames

%% Now, make the sensors

ieInit;

%%

sensor = sensorCreate('monochrome');
sensor = sensorSet(sensor, 'name', 'MTV9V024-Mono');
sensor = sensorSet(sensor, 'size', [480, 752]);

sensor = sensorSet(sensor, 'pixel size ', 6*1e-6);
sensor = pixelCenterFillPD(sensor, 0.8);

wave = 400:10:780;
[filterSpectra, filterNames] = ieReadColorFilter(wave, 'MT9V024_Mono.mat');
sensor = sensorSet(sensor, 'wave', wave);
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

% These values get us close to the numbers we expect from the literature
snr = pixelSNR(sensor);

fprintf('Max Pixel SNR:    %f (dB)\n', max(snr));
fprintf('Well capacity:    %d (electrons)\n', round(sensorGet(sensor, 'pixel well capacity')));
fprintf('Pixel read noise: %f (electrons)\n', sensorGet(sensor, 'pixel read noise electrons'));
fprintf('Sensor dynamic range:  %f dB\n', sensorDR(sensor, 1))

%%
oFile = fullfile(isetRootPath, 'data', 'sensor', 'auto', 'MT9V024SensorMono');
save(oFile, 'sensor');

%% The RGB version
sensor = sensorCreate;
sensor = sensorSet(sensor, 'name', 'MTV9V024-RGB');
sensor = sensorSet(sensor, 'size', [480, 752]);

sensor = sensorSet(sensor, 'pixel size ', 6*1e-6);
sensor = pixelCenterFillPD(sensor, 0.8);

wave = 400:10:780;
[filterSpectra, filterNames] = ieReadColorFilter(wave, 'MT9V024_RGB.mat');
sensor = sensorSet(sensor, 'wave', wave);
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
snr = pixelSNR(sensor);

fprintf('Max Pixel SNR:    %f (dB)\n', max(snr));
fprintf('Well capacity:    %d (electrons)\n', round(sensorGet(sensor, 'pixel well capacity')));
fprintf('Pixel read noise: %f (electrons)\n', sensorGet(sensor, 'pixel read noise electrons'));
fprintf('Sensor dynamic range:  %f dB\n', sensorDR(sensor, 1))

%%
oFile = fullfile(isetRootPath, 'data', 'sensor', 'auto', 'MT9V024SensorRGB');
save(oFile, 'sensor');

%% The RCCC version

sensor = sensorCreate;
sensor = sensorSet(sensor, 'name', 'MTV9V024-RCCC');
sensor = sensorSet(sensor, 'size', [480, 752]);

sensor = sensorSet(sensor, 'pixel size ', 6*1e-6);
sensor = pixelCenterFillPD(sensor, 0.8);

wave = 400:10:780;
[filterSpectra, filterNames] = ieReadColorFilter(wave, 'MT9V024_RCCC.mat');
sensor = sensorSet(sensor, 'wave', wave);
sensor = sensorSet(sensor, 'filter spectra', filterSpectra);
sensor = sensorSet(sensor, 'filter names', filterNames);
sensor = sensorSet(sensor, 'pattern', [2, 2; 2, 1]);

sensor = sensorSet(sensor, 'pixel read noise volts', 1e-3);
sensor = sensorSet(sensor, 'pixel voltage swing', 2.8);
sensor = sensorSet(sensor, 'pixel dark voltage', 1e-3);

% Example of well capacity curve as a function of pixel size
% http://www.clarkvision.com/articles/digital.sensor.performance.summary/#full_well
% We set the conversion gain to match the curve for a 4um pixel
sensor = sensorSet(sensor, 'pixel conversion gain', 110e-6);

%%
snr = pixelSNR(sensor);

fprintf('Max Pixel SNR:    %f (dB)\n', max(snr));
fprintf('Well capacity:    %d (electrons)\n', round(sensorGet(sensor, 'pixel well capacity')));
fprintf('Pixel read noise: %f (electrons)\n', sensorGet(sensor, 'pixel read noise electrons'));
fprintf('Sensor dynamic range:  %f dB\n', sensorDR(sensor, 1))

%%
oFile = fullfile(isetRootPath, 'data', 'sensor', 'auto', 'MT9V024SensorRCCC');
save(oFile, 'sensor');

%% The RGBW version

sensor = sensorCreate;
sensor = sensorSet(sensor, 'name', 'MTV9V024-RGBW');
sensor = sensorSet(sensor, 'size', [480, 752]);

sensor = sensorSet(sensor, 'pixel size ', 6*1e-6);
sensor = pixelCenterFillPD(sensor, 0.8);

wave = 400:10:780;
[filterSpectra, filterNames] = ieReadColorFilter(wave, 'MT9V024_RGBW.mat');
sensor = sensorSet(sensor, 'wave', wave);
sensor = sensorSet(sensor, 'filter spectra', filterSpectra);
sensor = sensorSet(sensor, 'filter names', filterNames);
sensor = sensorSet(sensor, 'pattern', [1, 2; 3, 4]);

sensor = sensorSet(sensor, 'pixel read noise volts', 1e-3);
sensor = sensorSet(sensor, 'pixel voltage swing', 2.8);
sensor = sensorSet(sensor, 'pixel dark voltage', 1e-3);

% Example of well capacity curve as a function of pixel size
% http://www.clarkvision.com/articles/digital.sensor.performance.summary/#full_well
% We set the conversion gain to match the curve for a 4um pixel
sensor = sensorSet(sensor, 'pixel conversion gain', 110e-6);

%%
snr = pixelSNR(sensor);

fprintf('Max Pixel SNR:    %f (dB)\n', max(snr));
fprintf('Well capacity:    %d (electrons)\n', round(sensorGet(sensor, 'pixel well capacity')));
fprintf('Pixel read noise: %f (electrons)\n', sensorGet(sensor, 'pixel read noise electrons'));
fprintf('Sensor dynamic range:  %f dB\n', sensorDR(sensor, 1))

%%
oFile = fullfile(isetRootPath, 'data', 'sensor', 'auto', 'MT9V024SensorRGBW');
save(oFile, 'sensor');
