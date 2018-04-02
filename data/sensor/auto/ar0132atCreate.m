%% AR0132AT - ON Semiconductor
%
% Simulation of the ON RGB automotive sensor
%
% There are separate files for the RCCC and Monochrome sensors
% (MT9VO24*)
%
% Copyright Imageval LLC, 2017

%% Make the color filters

chdir(fullfile(isetRootPath,'data','sensor','colorfilters','auto','ON','RGB'));

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
ieSaveColorFilter(cf,fullfile(isetRootPath,'data','sensor','colorfilters','auto','ar0132at.mat'));


%% Build up the sensor using parameters from spec sheet where possible

% RGB Bayer.  RG/GB
% Frame rate 45 Hz (full resolution)
sensorSize = [960 1280];    % Arbitrary
pixelSize = 3.751e-6;       % From sheet

% Fill factor

% Estimated to make other stuff seem about right
responsivity = 5.48;  % volts/lux-sec

MaxSNR = 43.9;        % dB
MaxDR  = 115;         % dB

% Spectral sensitivities
% Has a multi-exposure mode
sensor = sensorCreate;
sensor = sensorSet(sensor,'name','AR0132AT');
sensor = sensorSet(sensor,'size',sensorSize);
sensor = sensorSet(sensor,'pixel size same fill factor',pixelSize);

% We don't think it is backside illuminated.  If it were, we would set the
% photodetector size to be equal to the pixel size using the routine
% pixelCenterFillPD()

colorFilterFile = fullfile(isetRootPath,'data','sensor','colorfilters','auto','ar0132at.mat');

wave = sceneGet(scene,'wave');
[filterSpectra, filterNames] = ieReadColorFilter(wave,colorFilterFile);
sensor = sensorSet(sensor,'filter spectra',filterSpectra);
sensor = sensorSet(sensor,'filter names',filterNames);

sensor = sensorSet(sensor,'pixel read noise volts',1e-3);
sensor = sensorSet(sensor,'pixel voltage swing',2.8);
sensor = sensorSet(sensor,'pixel dark voltage',1e-3);

% Example of well capacity curve as a function of pixel size
% http://www.clarkvision.com/articles/digital.sensor.performance.summary/#full_well
% We set the conversion gain to match the curve for a 4um pixel
sensor = sensorSet(sensor,'pixel conversion gain',110e-6);

% These values get us close to the numbers we expect from the literature
snr = pixelSNR(sensor);

oFile = fullfile(isetRootPath,'data','sensor','auto','ar0132at');
save(oFile,'sensor');

%% Summary of AR0132AT properties in simulation
fprintf('Max Pixel SNR:    %f (dB)\n',max(snr));
fprintf('Well capacity:    %f (electrons)\n',round(sensorGet(sensor,'pixel well capacity')));
fprintf('Pixel read noise: %f (electrons)\n',sensorGet(sensor,'pixel read noise electrons'));
fprintf('Sensor dynamic range:  %f dB\n',sensorDR(sensor,1))

%%
