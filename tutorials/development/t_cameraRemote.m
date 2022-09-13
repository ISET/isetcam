%% t_cameraRemote
%
%  Read in an image file from the remote RGB data storage site and
%  run it through the camera simulation.
%
% Copyright Imageval Consulting, LLC, 2015

%%  Start ISET
ieInit

%% Read scene from the remote web site

remoteDir  = 'http://scarlet.stanford.edu/validation/SCIEN/RGB/LStryer';
remoteFile = 'twoBirds.jpg'; % 'darkIceWaves.jpg';
remote     = fullfile(remoteDir,remoteFile);
fname      = fullfile([tempname,'.jpg']);
[~,status] = urlwrite(remote,fname);
if ~status, error('Could not find remote data'); end

%% Read the local temporary file
d = displayCreate('LCD-Apple');
scene = sceneFromFile(fname,'rgb',[],d);
delete(fname);  % Clean up

scene = sceneSet(scene,'name',remoteFile);
scene = sceneAdjustIlluminant(scene,'D65.mat');
scene = sceneAdjustLuminance(scene,100); % Outdoor level
scene = sceneSet(scene,'fov',10);        % 10 deg field of view
scene = sceneSet(scene,'distance',30);   % 30 meters away
ieAddObject(scene); sceneWindow;

%%  Low resolution shot

camera = cameraCreate;
camera = cameraSet(camera,'name','low res');
camera = cameraSet(camera,'ip name','low res');

camera = cameraCompute(camera,scene);

cameraWindow(camera,'ip');
iePTable(camera);

ieAddObject(camera);   % Store the low res versions

%% High resolution shot

% Bring down the aperture and shrink the pixel size
camera = cameraSet(camera,'optics fnumber',2);
camera = cameraSet(camera,'pixel size same fill factor',[1.2 1.2]*1e-6);
camera = cameraSet(camera,'name','high res');
camera = cameraSet(camera,'ip name','high res');

camera = cameraCompute(camera,scene);

iePTable(camera);
ieAddObject(camera);  % Store the high res versions

%% View in the image processing window
%

ipWindow;

% If you would like to see the data in the oi or sensor window, go for it
% The data were stored there by the ieAddObject() calls above.
% oiWindow;
% sensorWindow;

%% END