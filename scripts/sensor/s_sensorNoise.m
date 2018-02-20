%% Measure different sensor noise 
%
%   *UPDATING IN PROGRESS*
%
% Multiple captures are needed to evaluate dynamic noise. This script is
% being updated
%
% Copyright Imageval Consulting, 2016

%%
ieInit

%% Simple spatial resolution scene

scene = sceneCreate('slanted bar');
scene = sceneSet(scene,'fov',4);
ieAddObject(scene); sceneWindow

% Optical image
oi = oiCreate;
oi = oiCompute(scene,oi);
ieAddObject(oi); oiWindow

%% Set the sensor noise properties

% Set up the sensor for a noise free calculation
sensor = sensorCreate;
sensor = sensorSet(sensor,'exp time',0.050);
sensor = sensorSet(sensor,'noise flag',0);

sensorNF = sensorCompute(sensor,oi);
v = sensorGet(sensorNF,'volts');

ieAddObject(sensorNF); sensorImageWindow
% sensorNF = vcGetObject('sensor');

%% Now compute with all noise terms on

nSamp = 100;
voltImages = sensorComputeSamples(sensorNF,nSamp);

%% Look at the noise histogram across all images
noiseImages = voltImages - repmat(v,[1 1 nSamp]);
vcNewGraphWin; hist(noiseImages(:),100)

%%
s = std(voltImages,0,3);
vcNewGraphWin;
imagesc(s); colorbar

%%
meanImage = mean(voltImages,3);
plot(meanImage(:),v(:),'.')
grid on;
axis equal

%%
s1 = sensorCompute(sensor,oi);
s2 = sensorCompute(sensor,oi);

v1 = sensorGet(s1,'volts');
v2 = sensorGet(s2,'volts');
hist(v1(:) - v2(:),100)

%%


