%% Calculate the number of rod absorptions to a uniform scene
%
% We simulate the rod absorptions to the LED device at its mean light
% level.
%
% We believe that there are about 750,000 absorptions per second per rod
% for this spectral power distribution at this level.  Rod thresholds under
% these conditions are probably far above 10% modulation.  So, we suspect
% that the visibility of the 4th photopigment signal is not the rods.
%
% Hiroshi Horiguchi, 2012.

% Deprecated

% %%
% if ~exist('ledSPD_pr715.mat','file'), error('Vistaproj colorTime must be on path'); end
%
% ieInit
%
% %% Set variables
%
% % Photopigment optical density
% rodpod = 0.05;
%
% RodinnerSegmentDiameter = 2.22; % 15 deg ecc. Curio 1993
% meanluminance = 2060; % cd/m2
% pupilsize = 2; % mm
%
% rodPeakAbsorbtance = 0.66; % from Rodieck
%
% %%
% scene = sceneCreate('uniform ee');
% wave  = sceneGet(scene,'wave');
%
% % Create a file with your primaries here.
% % fullpathname = ieSaveSpectralFile(wavelength,data,comment,[fullpathname]);
% % Or just load primaries.
% % Note that it requires a path to colorTime in vistaproj
% primaries = ieReadSpectra('ledSPD_pr715.mat',wave);
%
% % multiply your primaries by illEnergy
% illEnergy = primaries * ones(6,1);
%
% % apply illuminant energy to scene
% scene = sceneAdjustIlluminant(scene,illEnergy);
% % sceneGet(scene,'mean luminance') % you'll probably get 100 Cd/m2.
%
% % set luminance you desire
% scene = sceneSet(scene,'mean luminance', meanluminance);   % Cd/m2
% vcAddAndSelectObject(scene);sceneWindow(scene);
%
% %% create an optical image of human eye
% oi = oiCreate('human');
% optics = opticsCreate('human', pupilsize / 2 / 1000);
% oi = oiSet(oi,'optics',optics);
%
%
% % Calc rod responses
% % Note that it requires a path to colorTime in vistaproj
% rodabsorbance = ieReadSpectra('rodabsorbance.mat',wave);
% rods = cm_variableLMSI_PODandLambda(rodabsorbance, rodpod, [], LensTransmittance(wave));
% rods = rods * rodPeakAbsorbtance;
%
% % or
% % rods = ieReadSpectra('scotopicLuminosity.mat',wave);
% % vcNewGraphWin; plot(wave,rods)
%
%
% %% open an optical image window
% oi = oiCompute(scene,oi);
% vcAddAndSelectObject(oi);
% oiWindow;
%
% %%  Now set up the rod sensor parameters a little better
%
% RodArea  = (RodinnerSegmentDiameter./2)^2 * pi();
% Rodpixels = sqrt(RodArea);
%
% % Peak sensitivity - includes lens and rod pigment
% pixSize = Rodpixels*1e-6;
% sensor = sensorCreateIdeal('monochrome',pixSize);
%
% pixel = sensorGet(sensor,'pixel');
% % pixel = pixelSet(pixel,'width and height',    Rodpixels*1e-6);
% % pixel = pixelSet(pixel,'pd width and height', Rodpixels*1e-6);
% pixel = pixelSet(pixel,'voltageSwing',        300); % just for visualization
% % pixelGet(pixel,'fill factor')
%
% sensor = sensorSet(sensor,'pixel',pixel);
% sensor = sensorSet(sensor,'autoexposure',0);
% sensor = sensorSet(sensor,'exposureTime',1);
%
% sensor = sensorSet(sensor,'filter spectra',rods);
% sensor = sensorSet(sensor,'filter names',{'wrod'});
%
% sensor = sensorCompute(sensor,oi);
% vcAddAndSelectObject(sensor); sensorImageWindow
% %% Calculate number of absorptions (electrons) per rod
%
% sensor = vcGetObject('sensor');
% roi    = sensorROI(sensor,'center');
% sensor = sensorSet(sensor,'roi',roi);
% elROI  = sensorGet(sensor,'roi electrons');
%
% % mean of electron
% mean(elROI)
