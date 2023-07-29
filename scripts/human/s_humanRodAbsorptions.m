%% Calculate the number of rod absorptions to a uniform scene
%
% We simulate the rod absorptions to the LED device at its mean light
% level.
%
% We believe that there are about 750,000 absorptions per second per
% rod for the spectral power distribution of Hiroshi's rig and a 3mm
% pupil.  This calculation yields 700,000 absorptions.
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

% Simulate Hiroshi's display
primaries = ieReadSpectra('LED6-Melanopsin-HH.mat',wave);
ieNewGraphWin; plotRadiance(wave,primaries);

% Multiply your primaries by illEnergy
illEnergy = primaries * ones(6,1);

% Make the illuminant equal to the display primaries
scene = sceneAdjustIlluminant(scene,illEnergy);
% sceneGet(scene,'mean luminance') % you'll probably get 100 Cd/m2.

% Set the luminance level as calibrated
meanluminance      = 2060; % cd/m2
scene = sceneSet(scene,'mean luminance', meanluminance);   % Cd/m2

% sceneWindow(scene);

%% Create an optical image through the lens

% This includes the lens transmission
oi = oiCreate('wvf human',3);     % Pupil diameter in mm
% oiGet(oi,'optics pupil diameter','mm')

% open an optical image window
oi = oiCompute(oi,scene);
oi = oiCrop(oi,'border');
% oiWindow(oi);

% oiPlot(oi,'lens transmittance');

%% Make a coneMosaicRect with only one type of receptor (rods)

% The parameters to create a coneMosaicRect
params = coneMosaicRectParams;

% Specify only one type of receptor present
params.spatialDensity = [0,1,0,0];

% Make the rhodopsin photopigment. 
% It would be nice to have only one copy, but the coneMosaic is set up
% to require three.
wave = 400:700;

% This is the photopigment spectral sensitivity without the lens.  
tmp = ieReadSpectra('rods.mat',wave);
rods = repmat(tmp,1,3);

thisP = photoPigment('wave',wave, ...
    'absorbance',rods,...
    'peakEfficiency',[0.66,0 0 ],...
    'opticalDensity',[1 1 1]);

thisP.width   = 2.2*1e-6;      thisP.height = thisP.width;   % Curcio, 1993 at 15 deg
thisP.pdWidth = thisP.width; thisP.pdHeight = thisP.width;
params.pigment = thisP;

% Build the rect mosaic
cm = coneMosaicRect(params);

% One second integration time
cm.integrationTime = 1;

% No macular pigment over the rods
cm.macular.density = 0;
% ieNewGraphWin; plot(cm.macular.transmittance)

% This is the rod spectral QE (no lens, no macular pigment)
coneRectPlot(cm,'receptor spectral qe','receptor',1);

% Calculate the absorptions
cm.compute(oi);

% The numbers are similar, but not quite matching. I am comparing
% round vs. square pixels, for example.  Not sure what NC computes,
% and will ask.
fprintf('Absorptions:\t%.1f for round pixel area = %.3e um^2\n', mean(cm.absorptions(:)),pi*(thisP.width/2)^2);

% Per square micron, off by about 15 percent from below
mean(cm.absorptions(:))/(pi*(thisP.width*1e-6/2)^2)

% You can look and plot here
%
% cm.window;


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
wave = cm.wave;
rods = ieReadSpectra('scotopicLuminosity.mat',wave);
lensT = oiGet(oi,'optics transmittance',wave);
rods = ieScale(rods ./lensT,1);
rodPeakAbsorbtance = 0.66;             % from Rodieck
rods = rods*rodPeakAbsorbtance;
ieNewGraphWin; plot(wave,rods);

%%  Make sensor like a rod mosaic

% RodArea  = (RodinnerSegmentDiameter./2)^2 * pi;   % Microns
% Rodpixels = sqrt(RodArea);  % Microns
% pixSize = Rodpixels*1e-6;   % Meters % 15 deg ecc. Curio 1993

% The pixel size and the pupil size matter a lot for absorption counts
pixSize = 2.22*1e-6;   % Meters % 15 deg ecc. Curio 1993 is 2.22

sensor = sensorCreateIdeal('monochrome',[],[pixSize,pixSize]);
sensor = sensorSet(sensor,'pixel voltageSwing', 300); % No saturation
sensor = sensorSet(sensor,'pixel fill factor',1);     % Fraction
sensor = sensorSet(sensor,'autoexposure',0);   % Auto Off
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
fprintf('Absorptions:\t%.1f for square pixel area %.3e um^2\n',mean(elROI),prod(sensorGet(sensor,'pixel size','um')));

% Per square micron, off by about 15percent.
mean(elROI) / prod(sensorGet(sensor,'pixel size','um'))

%% END