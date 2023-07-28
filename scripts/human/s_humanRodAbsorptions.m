%% Calculate the number of rod absorptions to a uniform scene
%
% We simulate the rod absorptions to the LED device at its mean light
% level.
%
% We believe that there are about 750,000 absorptions per second per
% rod for the spectral power distribution of Hiroshi's rig and a 3mm
% pupil.
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


primaries = ieReadSpectra('LED6-Melanopsin-HH.mat',wave);
ieNewGraphWin; plotRadiance(wave,primaries);

% % multiply your primaries by illEnergy
illEnergy = primaries * ones(6,1);

% apply illuminant energy to scene
scene = sceneAdjustIlluminant(scene,illEnergy);
% sceneGet(scene,'mean luminance') % you'll probably get 100 Cd/m2.

% % set luminance you desire
meanluminance      = 2060; % cd/m2
scene = sceneSet(scene,'mean luminance', meanluminance);   % Cd/m2
% sceneWindow(scene);

%% create an optical image of human eye

% This includes the lens transmission
oi = oiCreate('wvf human',3);     % Pupil diameter in mm
oiGet(oi,'optics pupil diameter','mm')

% open an optical image window
oi = oiCompute(oi,scene);
oi = oiCrop(oi,'border');
oiWindow(oi);

% oiPlot(oi,'lens transmittance');

%% Make a coneMosaicRect with only one type of receptor

% Make the rhodopsin photopigment
wave = 400:700;
tmp = ieReadSpectra('rods.mat',wave);
rods = repmat(tmp,1,3);
thisP = photoPigment('wave',wave,'absorbance',rods,'peakEfficiency',[0.66,0.66,0.66], 'opticalDensity',[1 1 1]);

% Make a one receptor mosaic with the rhodopsin pigment
params = coneMosaicRectParams;
params.spatialDensity = [0,1,0,0];
params.pigment = thisP;
cm = coneMosaicRect(params);
cm.integrationTime = 1;
cm.patternSampleSize = [2.2 2.2]*1e-6;

% coneRectPlot(cm,'cone spectral qe');

cm.compute(oi);
cm.window;

% The numbers are a bit smaller than the ones below.
%

%%
% Calc rod responses
%{
% rodabsorbance = ieReadSpectra('rodabsorbance.mat',wave);
% rods = cm_variableLMSI_PODandLambda(rodabsorbance, rodpod, [], LensTransmittance(wave));
% rods = rods * rodPeakAbsorbtance;
%
%}

% %% Set variables
% Photopigment optical density
% rodpod = 0.05;
% RodinnerSegmentDiameter = 1.5; 
% RodinnerSegmentDiameter = 2.5; 
% RodinnerSegmentDiameter = 2.22; % 15 deg ecc. Curio 1993

% The scotopic luminosity includes the lens.  We already have the lens
% in the oi. So we divide that out
rods = ieReadSpectra('scotopicLuminosity.mat',wave);
lensT = oiGet(oi,'optics transmittance',wave);
rods = ieScale(rods ./lensT,1);
rodPeakAbsorbtance = 0.66;             % from Rodieck
rods = rods*rodPeakAbsorbtance;
ieNewGraphWin; plot(wave,rods)

%%  Make sensor like a rod mosaic

% RodArea  = (RodinnerSegmentDiameter./2)^2 * pi;   % Microns
% Rodpixels = sqrt(RodArea);  % Microns
% pixSize = Rodpixels*1e-6;   % Meters % 15 deg ecc. Curio 1993

% The pixel size and the pupil size matter a lot for absorption counts
pixSize = 2.22*1e-6;   % Meters % 15 deg ecc. Curio 1993 is 2.22

sensor = sensorCreateIdeal('monochrome');
sensor = sensorSet(sensor,'pixel size',pixSize);
sensor = sensorSet(sensor,'pixel voltageSwing', 300); % No saturation
sensor = sensorSet(sensor,'pixel fill factor',1);  % Fraction
sensor = sensorSet(sensor,'autoexposure',0);   % Off
sensor = sensorSet(sensor,'exposureTime',1);   % Seconds
sensor = sensorSet(sensor,'filter spectra',rods);
sensor = sensorSet(sensor,'filter names',{'wrod'});

sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor); 

%% Calculate number of absorptions (electrons) per rod

roi    = sensorROI(sensor,'center');
sensor = sensorSet(sensor,'roi',roi);
elROI  = sensorGet(sensor,'roi electrons');

% mean of electron
fprintf('Absorptions: %.1f for pixel size (%.2f %.2f)\n',mean(elROI),sensorGet(sensor,'pixel size','um'));

%% END