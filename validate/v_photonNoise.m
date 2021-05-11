% v_photonNoise
%
% Check the routines that generate photon noise for oiPhotonNoise and
% noiseShot
%
% Copyright 2013, Imageval, LLC

%%
ieInit

%% Create a uniform scene with few photons.

% The small number of photons gives us a chance to see the noise
% distribution on the signal.
scene = sceneCreate('uniform');
scene = sceneSet(scene, 'fov', 20); % Pretty big
scene = sceneAdjustLuminance(scene, 10^-11);
% ieAddObject(scene); sceneWindow

%% Create and crop out center of OI
oi = oiCreate;

% No lens shading
optics = oiGet(oi, 'optics');
optics = opticsSet(optics, 'cos4th', 'off');
oi = oiSet(oi, 'optics', optics);

oi = oiCompute(oi, scene);
% Reset the rect if you adjust any sizes
% ieAddObject(oi); oiWindow
% [oi,rect] = oiCrop(oi);

rect = [6, 6, 29, 29]; % Middle part
oi = oiCrop(oi, rect);
% ieAddObject(oi); oiWindow

%% Compare the variance of the photon noise and the mean level
photons = oiGet(oi, 'photons');
pMean = photons(:, :, 10);
mean(pMean(:));

noisyPhotons = oiGet(oi, 'photons with noise');
pNoise = noisyPhotons(:, :, 10) - photons(:, :, 10);
% vcNewGraphWin; hist(pNoise(:))

% This should be close to 1
t = var(pNoise(:)) / mean(pMean(:));
fprintf('Should be near 1:  %f\n', t);
% assert(abs(t - 1) < 0.1)
