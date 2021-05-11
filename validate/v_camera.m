%% v_camera
%
% Tests creation of the camera structure, making sure that it uses the
% oi and sensor that are currently in the database by default.

%%
ieInit

%% Test that 'ideal' cameraCreate works
c = cameraCreate('ideal');
assert(cameraGet(c, 'sensor noise flag') == 1);
assert(cameraGet(c, 'sensor nfilters') == 1);
fprintf('Ideal noise flag %d. Nfilters = %d\n', ...
    cameraGet(c, 'sensor noise flag'), cameraGet(c, 'sensor nfilters'));

%% Test cameraCreate for 'current'
oi = oiCreate;
optics = oiGet(oi, 'optics');
optics = opticsSet(optics, 'fnumber', 22);
oi = oiSet(oi, 'optics', optics);
ieAddObject(oi);

%%  Sensor added to environment

sensor = sensorCreate('human');
noiseFlag = sensorGet(sensor, 'noise flag');
ieAddObject(sensor);

%% These should be the names of the objects built aboves
c = cameraCreate('current');
assert(strncmp(cameraGet(c, 'sensor name'), 'human', 5));
assert(cameraGet(c, 'optics fnumber') == 22); % 22
assert(cameraGet(c, 'sensor noise flag') == noiseFlag); % 2
cameraGet(c, 'pixel size', 'um') % 1.5 um

% Nothing to see
% cameraWindow(c);

%%