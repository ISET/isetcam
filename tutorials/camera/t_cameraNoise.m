%% Use the camera object to control different types of sensor noise
%
%   Read an interesting image
%   Show the image at a high light level
%   Show the image at a reduced light level
%   Set up to illustrate the effects with different amounts of noise
%
% BW, Imageval LLC, 2016

%%
ieInit;

% Build a default camera with optics, sensor and image processing
camera = cameraCreate;
camera = cameraSet(camera,'optics fnumber',2);

%% Download an interesting scene
% if ~exist('RdtClient', 'file'), return; end
% rd = RdtClient('isetbio');
% rd.crp('/resources/scenes/multiband/scien/2008');
% 
% % Here are the scenes in the remote data base in that directory
% rd.listArtifacts('print',true);
% 
% % Load the scene, which is in the form of a basis.
% d = rd.readArtifact('AsianWoman');
% 
% % Convert from basis to a scene
% s = sceneFromBasis(d);

s = sceneFromFile('faceMale.jpg','rgb',[],displayCreate);

sceneWindow(s);

%% Turn off all noise and compute through the lens and so forth

camera = cameraSet(camera,'sensor noise flag',0);

% Set the exposure duration to 50 ms
camera = cameraSet(camera,'sensor exp time',0.01);

camera = cameraCompute(camera,s);

% Show the final result
camera = cameraSet(camera,'ip name','No noise');
cameraWindow(camera,'ip');

%% Now allow the noise and sweep out some of the variables

% First, just photon noise
camera = cameraSet(camera,'sensor noise flag',1);

% At low light levels, the photon noise visibility is considerable
s = sceneAdjustLuminance(s,5);  % 5 cd/m2
camera = cameraCompute(camera,s);
camera = cameraSet(camera,'ip name','Photon noise');
cameraWindow(camera,'ip');

%% Include all noise types

camera = cameraSet(camera,'sensor noise flag',2);

% Increase the illumination
s = sceneAdjustLuminance(s,100);  % 5 cd/m2

%% Edit these noise parameters and explore their effects

readNoise = 0.0;     % 0.01, cameraGet(camera,'pixel voltage swing')
darkVoltage = 0;     % 1,    cameraGet(camera,'pixel dark voltage')
dsnu = 0.0;          % 0.01, cameraGet(camera,'sensor dsnu level')
prnu = 0;            % 5,    cameraGet(camera,'sensor prnu level')

camera = cameraSet(camera,'pixel read noise volts',readNoise); % Volts
camera = cameraSet(camera,'pixel dark voltage',darkVoltage);  % Volts
camera = cameraSet(camera,'sensor dsnu level',dsnu); % Std dev in volts
camera = cameraSet(camera,'sensor prnu level',prnu);   % Percent variation

camera = cameraCompute(camera,s);
cameraWindow(camera,'ip');

%% END