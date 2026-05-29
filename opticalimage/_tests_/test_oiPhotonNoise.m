function tests = test_oiPhotonNoise()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
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
scene = sceneSet(scene,'fov',20);  % Pretty big
scene = sceneAdjustLuminance(scene,10^-11);
% ieAddObject(scene); sceneWindow

%% Create and crop out center of OI
oi = oiCreate;

% No lens shading
optics = oiGet(oi,'optics');
optics = opticsSet(optics,'cos4th','off');
oi = oiSet(oi,'optics',optics);

oi = oiCompute(oi, scene);
% Reset the rect if you adjust any sizes
% ieAddObject(oi); oiWindow
% [oi,rect] = oiCrop(oi);

rect = [6 6 29 29];  % Middle part
oi = oiCrop(oi,rect);
% ieAddObject(oi); oiWindow

%% Compare the mean of the photons with and without noise
photons = oiGet(oi,'photons');
noisyPhotons = oiGet(oi,'photons with noise');
assert(abs(mean(photons,'all')/mean(noisyPhotons,'all') - 1) < 1e-2);

% ieNewGraphWin; histogram(pNoise(:))

%% For one wavelength, the variance of the noise should be equal to the mean

p = photons(:,:,10); p = p(:);
n = noisyPhotons(:,:,10); n = n(:);
meanPhotons = mean(p,'all');
varPhotons  = var(p - n);
assert(abs(meanPhotons/varPhotons - 1) < 0.1)

%%
end
