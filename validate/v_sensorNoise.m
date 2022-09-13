%% v_sensorNoise
%
% Create a set of images with sensor noise computations in various states.
% The noise is either turned on or off fully, just the photon noise, or we
% have the noise in a reuse state.
%
% See the header to sensorCompute to understand the meaning of the
% different noiseFlag values.
%
% Copyright ImagEval, LLC, 2011

%%
ieInit

%%
scene = sceneCreate;
oi = oiCreate;
oi = oiCompute(scene,oi);

%%
sensor = sensorCreate;
sensor = sensorSet(sensor,'exp time',0.050);

sensor = sensorCompute(sensor,oi);
sensor = sensorSet(sensor,'name','original');
sensorWindow(sensor);

%% No noise, just compute the mean, no quantization, clipping or analog gain and offset
sensor = sensorSet(sensor,'noiseFlag',-1);
sensorMean = sensorCompute(sensor,oi);
sensorMean = sensorSet(sensorMean,'name','mean');
sensorWindow(sensorMean);


%% No noise, but include quantization, clipping, analog gain/offset
sensor = sensorSet(sensor,'noiseFlag',0);
sensorMean = sensorCompute(sensor,oi);
sensorMean = sensorSet(sensorMean,'name','mean');
sensorWindow(sensorMean);

%% Photon noise but non electronic noise (includes q/c/a)
sensor = sensorSet(sensor,'noiseFlag',1);
sensorPhotonNoise = sensorCompute(sensor,oi);
sensorPhotonNoise = sensorSet(sensorPhotonNoise,'name','photon noise');

sensorWindow(sensorPhotonNoise);

%% Photon and electrical noise q/c/a
sensor = sensorSet(sensor,'noiseFlag',2);
sensorAllNoise = sensorCompute(sensor,oi);
sensorAllNoise = sensorSet(sensorAllNoise,'name','all noise');

sensorWindow(sensorAllNoise);

%% Reuse the noise
sensorAllNoise  = sensorSet(sensorAllNoise,'reuse noise',1);
sensorAllNoise2 = sensorCompute(sensorAllNoise,oi);
sensorAllNoise2 = sensorSet(sensorAllNoise2,'name','all noise2');

v1 = sensorGet(sensorAllNoise,'volts');
v2 = sensorGet(sensorAllNoise2,'volts');
vcNewGraphWin; plot(v1(:),v2(:),'.')
title('Should be identity line')
assert(max(abs(v1(:) - v2(:))) < 1e-6,'Reused noise difference too large')

%% Do not reuse the noise
sensorAllNoise  = sensorSet(sensorAllNoise,'reuse noise',0);
sensorAllNoise3 = sensorCompute(sensorAllNoise,oi);
sensorAllNoise3 = sensorSet(sensorAllNoise3,'name','all noise2');

v1 = sensorGet(sensorAllNoise,'volts');
v2 = sensorGet(sensorAllNoise3,'volts');
vcNewGraphWin; plot(v1(:),v2(:),'.')
title('Should be scattered')
assert(max(abs(v1(:) - v2(:))) > 1e-4,'Reused noise difference too small')

%% Add noise to the mean
sensor = sensorSet(sensor,'noise flag',-1);   % No noise, clipping, nothing
sensorMean = sensorCompute(sensor,oi);
sensorMean = sensorSet(sensorMean,'name','mean');
sensorWindow(sensorMean);

sensorMean  = sensorSet(sensorMean,'noise flag',1);
sensorNoise = sensorComputeNoise(sensorMean,[]);
sensorNoise = sensorSet(sensorNoise,'name','meanPlusNoise');
sensorWindow(sensorNoise);

v1 = sensorGet(sensorMean,'volts');
v2 = sensorGet(sensorNoise,'volts');
vcNewGraphWin; plot(v1(:),v2(:),'.')
xlabel('No noise'); ylabel('General noise');
title('Should be scattered')

% The photon noise, clipping, and quantization errors
vcNewGraphWin; histogram(v1(:) - v2(:),100);
xlabel('Volts')
ylabel('Pixel count')
title('Noise photon, clipping, quantization)')

%%  Let's try the functions on two or three test scenes.

% Let's do grid lines
%
scene = sceneCreate('grid lines');
scene = sceneSet(scene,'fov',3);

oi = oiCreate('human');   % Default optics
oi = oiCompute(scene,oi);
sensor = sensorCreate('bayer-rggb');
sensor = sensorSet(sensor,'exp time',0.1);

%%  Let's try running twice with no noise

% Turn off the noise and create the data
sensorNew = sensorSet(sensor,'noiseFlag',0);

% Now, we run the new version
sensorNew1 = sensorCompute(sensorNew,oi);
sensorNew2 = sensorCompute(sensorNew,oi);

ieAddObject(sensorNew1);
sensorWindow(sensorNew2);

%% Should be IDENTICAL

v1 = sensorGet(sensorNew1,'volts');
v2 = sensorGet(sensorNew2,'volts');
vcNewGraphWin; plot(v1(:),v2(:),'.');
grid on
xlabel('sensor 1')
xlabel('sensor 2')

%% Set sensorNew to reuse the same

% Create a fresh sample with noise
sensorNew      = sensorSet(sensorNew,'noise flag',2);   %Include all noise
sensorNew      = sensorSet(sensorNew,'reuse noise',0);  %Don't reuse
sensorNew      = sensorCompute(sensorNew,oi);

sensorNew      = sensorSet(sensorNew,'reuse noise',1);  %Reuse
sensorNewReuse = sensorCompute(sensorNew,oi);

%%
v1 = sensorGet(sensorNew,'volts');
v2 = sensorGet(sensorNewReuse,'volts');
vcNewGraphWin; plot(v1(:),v2(:),'.');
grid on
xlabel('sensor original')
xlabel('sensor reuse')

%% End