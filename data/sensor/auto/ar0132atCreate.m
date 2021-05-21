%% AR0132AT - ON Semiconductor RGB sensor
%
% Simulation of an ON/Aptina RGB automotive sensor with smaller pixels than
% the MT9V024 version.  This has a 3.75 micron pixels and that one has 6
% micron pixels.
%
% Copyright Imageval LLC, 2017

%% Make the color filters

chdir(fullfile(isetRootPath,'data','sensor','colorfilters','auto','ON','RGB'));

%% RGB version

% Data run out from 350 to 1050
load('RedChannel.mat');
load('GreenChannel.mat');
load('BlueChannel.mat');

wave = 380:1:1000;
R = interp1(RedChannel(:,1),RedChannel(:,2),wave,'linear','extrap');
G = interp1(GreenChannel(:,1),GreenChannel(:,2),wave,'linear','extrap');
B = interp1(BlueChannel(:,1),BlueChannel(:,2),wave,'linear','extrap');

vcNewGraphWin;
ar0132at = [R(:) G(:) B(:)];
ar0132at = ar0132at/max(ar0132at(:));
plot(wave,ar0132at); grid on

cf.wavelength = wave;
cf.data = ar0132at;
cf.filterNames = {'rAR0132','gAR0132','bAR0132'};
cf.comment = 'Grabit from ar0132at data sheet.  See 2017 Vehicle folder';
ieSaveColorFilter(cf,fullfile(isetRootPath,'data','sensor','colorfilters','auto','ar0132atRGB.mat'));

%% RGBW version

chdir(fullfile(isetRootPath,'data','sensor','colorfilters','auto','ON','RGB'));

% Data run out from 350 to 1050
load('RedChannel.mat');
load('GreenChannel.mat');
load('BlueChannel.mat');

chdir(fullfile(isetRootPath,'data','sensor','colorfilters','auto','ON','Mono'));
load('Mono.mat');

wave = 380:1:1000;
R = interp1(RedChannel(:,1),RedChannel(:,2),wave,'linear','extrap');
G = interp1(GreenChannel(:,1),GreenChannel(:,2),wave,'linear','extrap');
B = interp1(BlueChannel(:,1),BlueChannel(:,2),wave,'linear','extrap');
W = interp1(Mono(:,1),Mono(:,2),wave,'linear','extrap');

vcNewGraphWin;
ar0132at = [R(:) G(:) B(:) W(:)];
ar0132at = ar0132at/max(ar0132at(:));
plot(wave,ar0132at); grid on

%% Save RGBW filters

cf.wavelength = wave;
cf.data = ar0132at;
cf.filterNames = {'rAR0132','gAR0132','bAR0132','wAR0132'};
cf.comment = 'Grabit from ar0132at data sheet.  See 2017 Vehicle folder';
ieSaveColorFilter(cf,fullfile(isetRootPath,'data','sensor','colorfilters','auto','ar0132atRGBW.mat'));

%% Save RCCC filters
chdir(fullfile(isetRootPath,'data','sensor','colorfilters','auto','ON','RCCC'));

load('r_RCCC.mat','r_RCCC')
R = interp1(r_RCCC(:,1),r_RCCC(:,2),wave,'linear','extrap');
R = R/100;

load('c_RCCC.mat','c_RCCC')
C = interp1(c_RCCC(:,1),c_RCCC(:,2),wave,'linear','extrap');
C = C/100;

vcNewGraphWin;
ar0132at = [R(:) C(:)];
ar0132at = ar0132at/max(ar0132at(:));
plot(wave,ar0132at); grid on

%% Save RCCC filters

cf.wavelength = wave;
cf.data = ar0132at;
cf.filterNames = {'rAR0132','wAR0132'};
cf.comment = 'Grabit from ar0132at data sheet.  See 2017 Vehicle folder';
ieSaveColorFilter(cf,fullfile(isetRootPath,'data','sensor','colorfilters','auto','ar0132atRCCC.mat'));


%% Store basic sensor geometry and other properties

% RGB Bayer.  RG/GB
% Frame rate 45 Hz (full resolution)
sensorSize = [960 1280];    % Arbitrary
pixelSize = 3.751e-6;       % From sheet

% Fill factor
% Read noise?

% Estimated to make other stuff seem about right
responsivity = 5.48;  % volts/lux-sec

MaxSNR = 43.9;        % dB
MaxDR  = 115;         % dB

readNoise = 1e-3;
voltageSwing = 2.8;
darkVoltage = 1e-3;

% Example of well capacity curve as a function of pixel size
% http://www.clarkvision.com/articles/digital.sensor.performance.summary/#full_well
% We set the conversion gain to match the curve for a 4um pixel
conversionGain = 110e-6;

%% Build up the RGB sensor using parameters from spec sheet where possible

% Spectral sensitivities
% Has a multi-exposure mode
sensor = sensorCreate;
sensor = sensorSet(sensor,'name','AR0132AT-RGB');
sensor = sensorSet(sensor,'size',sensorSize);
sensor = sensorSet(sensor,'pixel size same fill factor',pixelSize);

% We don't think it is backside illuminated.  If it were, we would set the
% photodetector size to be equal to the pixel size using the routine
% pixelCenterFillPD()

colorFilterFile = fullfile(isetRootPath,'data','sensor','colorfilters','auto','ar0132atRGB.mat');

wave = [400:10:700];
[filterSpectra, filterNames] = ieReadColorFilter(wave,colorFilterFile);
sensor = sensorSet(sensor,'wave',wave);
sensor = sensorSet(sensor,'filter spectra',filterSpectra);
sensor = sensorSet(sensor,'filter names',filterNames);

sensor = sensorSet(sensor,'pixel read noise volts',readNoise);
sensor = sensorSet(sensor,'pixel voltage swing',voltageSwing);
sensor = sensorSet(sensor,'pixel dark voltage',darkVoltage);
sensor = sensorSet(sensor,'pixel conversion gain',conversionGain);

% These values get us close to the numbers we expect from the literature
snr = pixelSNR(sensor);

oFile = fullfile(isetRootPath,'data','sensor','auto','ar0132atSensorRGB');
save(oFile,'sensor');

%% Summary of AR0132AT properties in simulation

fprintf('Max Pixel SNR:    %f (dB)\n',max(snr));
fprintf('Well capacity:    %f (electrons)\n',round(sensorGet(sensor,'pixel well capacity')));
fprintf('Pixel read noise: %f (electrons)\n',sensorGet(sensor,'pixel read noise electrons'));
fprintf('Sensor dynamic range:  %f dB\n',sensorDR(sensor,1))

%% Build up the RGBW sensor using parameters from spec sheet where possible

% Spectral sensitivities
% Has a multi-exposure mode
sensor = sensorCreate;
sensor = sensorSet(sensor,'name','AR0132AT-RGBW');
sensor = sensorSet(sensor,'size',sensorSize);
sensor = sensorSet(sensor,'pixel size same fill factor',pixelSize);

% We don't think it is backside illuminated.  If it were, we would set the
% photodetector size to be equal to the pixel size using the routine
% pixelCenterFillPD()

colorFilterFile = fullfile(isetRootPath,'data','sensor','colorfilters','auto','ar0132atRGBW.mat');

wave = [400:10:700];
[filterSpectra, filterNames] = ieReadColorFilter(wave,colorFilterFile);
sensor = sensorSet(sensor,'wave',wave);
sensor = sensorSet(sensor,'filter spectra',filterSpectra);
sensor = sensorSet(sensor,'filter names',filterNames);

sensor = sensorSet(sensor,'pixel read noise volts',readNoise);
sensor = sensorSet(sensor,'pixel voltage swing',voltageSwing);
sensor = sensorSet(sensor,'pixel dark voltage',darkVoltage);
sensor = sensorSet(sensor,'pixel conversion gain',conversionGain);

% These values get us close to the numbers we expect from the literature
snr = pixelSNR(sensor);

%% Summary of AR0132AT properties in simulation
fprintf('Max Pixel SNR:    %f (dB)\n',max(snr));
fprintf('Well capacity:    %f (electrons)\n',round(sensorGet(sensor,'pixel well capacity')));
fprintf('Pixel read noise: %f (electrons)\n',sensorGet(sensor,'pixel read noise electrons'));
fprintf('Sensor dynamic range:  %f dB\n',sensorDR(sensor,1))

%% Save the RGBW sensor

oFile = fullfile(isetRootPath,'data','sensor','auto','ar0132atSensorRGBW');
save(oFile,'sensor');

%% Build up the RCCC sensor using parameters from spec sheet where possible

% Spectral sensitivities
% Has a multi-exposure mode
sensor = sensorCreate;
sensor = sensorSet(sensor,'name','AR0132AT-RCCC');
sensor = sensorSet(sensor,'size',sensorSize);
sensor = sensorSet(sensor,'pixel size same fill factor',pixelSize);

% We don't think it is backside illuminated.  If it were, we would set the
% photodetector size to be equal to the pixel size using the routine
% pixelCenterFillPD()

colorFilterFile = fullfile(isetRootPath,'data','sensor','colorfilters','auto','ar0132atRCCC.mat');

wave = [400:10:700];
[filterSpectra, filterNames] = ieReadColorFilter(wave,colorFilterFile);
sensor = sensorSet(sensor,'wave',wave);
sensor = sensorSet(sensor,'filter spectra',filterSpectra);
sensor = sensorSet(sensor,'filter names',filterNames);

sensor = sensorSet(sensor,'pixel read noise volts',readNoise);
sensor = sensorSet(sensor,'pixel voltage swing',voltageSwing);
sensor = sensorSet(sensor,'pixel dark voltage',darkVoltage);
sensor = sensorSet(sensor,'pixel conversion gain',conversionGain);

sensor = sensorSet(sensor,'pattern',[2 2; 2 1]);

% Example of well capacity curve as a function of pixel size
% http://www.clarkvision.com/articles/digital.sensor.performance.summary/#full_well
% We set the conversion gain to match the curve for a 4um pixel

% These values get us close to the numbers we expect from the literature
snr = pixelSNR(sensor);

%% Summary of AR0132AT properties in simulation
fprintf('Max Pixel SNR:    %f (dB)\n',max(snr));
fprintf('Well capacity:    %f (electrons)\n',round(sensorGet(sensor,'pixel well capacity')));
fprintf('Pixel read noise: %f (electrons)\n',sensorGet(sensor,'pixel read noise electrons'));
fprintf('Sensor dynamic range:  %f dB\n',sensorDR(sensor,1))

%%
oFile = fullfile(isetRootPath,'data','sensor','auto','ar0132atSensorRCCC');
save(oFile,'sensor');
