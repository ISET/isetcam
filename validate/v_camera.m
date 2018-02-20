%% v_camera
%
%
%
% Validation tests for the camera object

%% Test for 'ideal' cameraCreate call
c = cameraCreate('ideal');
cameraGet(c,'sensor noise flag')
cameraGet(c,'sensor nfilters')

%% Test cameraCreate for 'current'
oi     = oiCreate;
optics = oiGet(oi,'optics');
optics =  opticsSet(optics,'fnumber',22);
oi     = oiSet(oi,'optics',optics);
ieAddObject(oi);

sensor = sensorCreate('human');
ieAddObject(sensor);

%
c = cameraCreate('current');
cameraGet(c,'sensor name')       % human-XX
cameraGet(c,'optics fnumber')    % 22
cameraGet(c,'sensor noise flag') % 2
cameraGet(c,'pixel size','um')   % 1.5 um

%%