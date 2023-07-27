%% Calculate the number of rod absorptions to a uniform scene
%
% We simulate the rod absorptions to the LED device at its mean light
% level.
%
% We believe that there are about 750,000 absorptions per second per
% rod for this spectral power distribution at this level.  The number
% we calculate here is closely and could be that if the rod aperture
% is 2.5 microns rather than 2.2 microns. 
% 
% Hiroshi Horiguchi, 2012 initiated as part of his PNAS paper on
% melanopsin.
%
% See also
%   v_calibration*

%%
ieInit

%%
scene = sceneCreate('uniform ee');
wave  = sceneGet(scene,'wave');
%
% % Create a file with your primaries here.
% % fullpathname = ieSaveSpectralFile(wavelength,data,comment,[fullpathname]);
% % Or just load primaries.
% % Note that it requires a path to colorTime in vistaproj
% primaries = ieReadSpectra('ledSPD_pr715.mat',wave);

primaries = ieReadSpectra('LED6-Melanopsin-HH.mat',wave);
ieNewGraphWin; plotRadiance(wave,primaries);

% % multiply your primaries by illEnergy
illEnergy = primaries * ones(6,1);
%
% % apply illuminant energy to scene
scene = sceneAdjustIlluminant(scene,illEnergy);
% sceneGet(scene,'mean luminance') % you'll probably get 100 Cd/m2.
%
% % set luminance you desire
scene = sceneSet(scene,'mean luminance', meanluminance);   % Cd/m2
sceneWindow(scene);

%% create an optical image of human eye

% This includes the lens transmission
oi = oiCreate('wvf human');
oi = oiSet(oi,'optics',optics);
oiGet(oi,'optics pupil diameter')

% open an optical image window
oi = oiCompute(oi,scene);
oi = oiCrop(oi,'border');
oiWindow(oi);

% oiPlot(oi,'lens transmittance');

%%  Now set up a sensor (should be coneMosaicRect) of only rods

% Calc rod responses
%{
% rodabsorbance = ieReadSpectra('rodabsorbance.mat',wave);
% rods = cm_variableLMSI_PODandLambda(rodabsorbance, rodpod, [], LensTransmittance(wave));
% rods = rods * rodPeakAbsorbtance;
%
%}

% %% Set variables
%
% Photopigment optical density
rodpod = 0.05;

% RodinnerSegmentDiameter = 2.22; % 15 deg ecc. Curio 1993
% RodinnerSegmentDiameter = 1.5; % 15 deg ecc. Curio 1993
RodinnerSegmentDiameter = 2.5; % 15 deg ecc. Curio 1993
meanluminance = 2060; % cd/m2
rodPeakAbsorbtance = 0.66; % from Rodieck
%

% This also includes the lens transmittance.  So we divide that out
rods = ieReadSpectra('scotopicLuminosity.mat',wave);
lensT = oiGet(oi,'optics transmittance');
rods = ieScale(rods ./lensT,1);
rods = rods*rodPeakAbsorbtance;

ieNewGraphWin; plot(wave,rods)

%%  
RodArea  = (RodinnerSegmentDiameter./2)^2 * pi;   % Microns
Rodpixels = sqrt(RodArea);  % Microns
pixSize = Rodpixels*1e-6;   % Meters
sensor = sensorCreateIdeal('monochrome');
sensor = sensorSet(sensor,'pixel size',pixSize);
sensor = sensorSet(sensor,'pixel voltageSwing', 300); % No saturation
sensor = sensorSet(sensor,'pixel fill factor',1);  % Fraction
sensor = sensorSet(sensor,'autoexposure',0);   % Off
sensor = sensorSet(sensor,'exposureTime',1);   % Seconds

%
sensor = sensorSet(sensor,'filter spectra',rods);
sensor = sensorSet(sensor,'filter names',{'wrod'});

sensor = sensorCompute(sensor,oi);

sensorWindow(sensor); 

%% Calculate number of absorptions (electrons) per rod

roi    = sensorROI(sensor,'center');
sensor = sensorSet(sensor,'roi',roi);
elROI  = sensorGet(sensor,'roi electrons');

% mean of electron
mean(elROI)
