%% AR0132AT - ON Semiconductor
%
%  The ON RGB automotive sensor
%
%  There are separate files for the RCCC and Monochrome sensors
%  (MT9V024Create) and (???)
%
% Copyright Imageval LLC, 2017

%%
chdir(fullfile(isetRootPath,'data','sensor','CMOS'));

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
ieSaveColorFilter(cf,fullfile(isetRootPath,'data','sensor','CMOS','ar0132at.mat'));


%% Parameters from sheet
% RGB Bayer.  RG/GB
% Frame rate 45 Hz (full resolution)

sensorSize = [960 1280];    % Not important, really, but OK
pixelSize = 3.751e-6; % 

% Fill factor

responsivity = 5.48;  % volts/lux-sec

MaxSNR = 43.9;        % dB
MaxDR  = 115;         % dB

% Spectral sensitivities
% Has a multi-exposure mode

%% Test oi
%{
scene = sceneCreate('sweep frequency',1024,20);
scene = sceneSet(scene,'fov',45);
ieAddObject(scene);

oi = oiCreate;
oi = oiSet(oi,'optics fnumber',2.8);

oi = oiCompute(oi,scene);
%}
%% Here is the car example
dataDir = fullfile(userpath,'publications','talks_Berlin');
load(fullfile(dataDir,'carOi.mat'),'oi');
% p = oiGet(oi,'photons');
% scene = sceneCreate;
% scene = sceneSet(scene,'wave',oiGet(oi,'wave'));
% scene = sceneSet(scene,'photons',p);
% scene = sceneAdjustLuminance(scene,100);
% scene = sceneSet(scene,'fov',45);
% scene = sceneSet(scene,'distance',7);
% ieAddObject(scene); sceneWindow;

% oi = oiCreate;
% oi = oiSet(oi,'optics f number',4);
% oi = oiCompute(oi,scene);

ieAddObject(oi); oiWindow;

%%
sensor = sensorCreate;
sensor = sensorSet(sensor,'size',sensorSize);
sensor = sensorSet(sensor,'pixel size same fill factor',pixelSize);
% We don't think it is backside illuminated.  If it were, we would set the
% photodetector size to be equal to the pixel size using the routine
% pixelCenterFillPD()

colorFilterFile = fullfile(isetRootPath,'data','sensor','CMOS','ar0132at.mat');

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
fprintf('Max Pixel SNR is %f\n',max(snr));
fprintf('Well capacity in electrons %f\n',sensorGet(sensor,'pixel well capacity'));
sensorGet(sensor,'pixel read noise electrons')

%%
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor);
sensorWindow;
%%
sensorDR(sensor,1)

%%
