%% Create a sensor with a rectangular pixel
%
%  Illustrates how to create a sensor for dual pixel autofocus experiments
%  (DPAF).
%
%  In other scripts we create thi sensor and put a single microlens on top
%  of the two pixels.
%
% See also
%  s_sensorDPAF

% We are planning for a sensor that has twice as many columns as rows. Each
% pixel is rectangular with 2.8 um height and 1.4 micron width.

%% Initialize a scene and oi
ieInit;
if ~piDockerExists, piDockerConfig; end
chdir(fullfile(piRootPath,'local'));

%%  Get the chess set scene

thisR = piRecipeDefault('scene name','chessSet'); 

%% Set up the combined imaging and microlens array

uLensName = 'microlens.json';
iLensName = 'dgauss.22deg.3.0mm.json';
uLensHeight = 0.0028;        % 2.8 um - each covers two pixels
nMicrolens = [40 40]*5;      % Appears to work for rectangular case, too

[combinedLensFile, uLens, iLens] = lensCombine(uLensName,iLensName,uLensHeight,nMicrolens);

thisR.camera = piCameraCreate('omni','lensFile',combinedLensFile);

%% Set up the film parameters
%
% We want the OI to be calculated at 4 positions behind each microlens.
% There will be two positions for each of the pixels.  The pair of up/down
% positions will be summed by the sensor into a single pixel response.  The
% pair of left/right positions will be the two pixels behind the microlens.
%

pixelsPerMicrolens = 2;

pixelSize  = uLens.get('lens height')/pixelsPerMicrolens;   % mm
filmwidth  = nMicrolens(2)*uLens.get('diameter','mm');       % mm
filmheight = nMicrolens(1)*uLens.get('diameter','mm');       % mm
filmresolution = [filmheight, filmwidth]/pixelSize;

thisR.set('focus distance',0.6);

% This is the size of the film/sensor in millimeters 
thisR.set('film diagonal',sqrt(filmwidth^2 + filmheight^2));

% Film resolution -
thisR.set('film resolution',filmresolution);

% This is the aperture of the imaging lens of the camera in mm
thisR.set('aperture diameter',6);   

%% Make a dual pixel sensor that has rectangular pixels
%

% Turn this into a function like sensorCreate('dual pixel');

sensor = sensorCreate;
sz = sensorGet(sensor,'pixel size');

% We make the height 
sensor = sensorSet(sensor,'pixel width',sz(2)/2);

% Add more columns
rowcol = sensorGet(sensor,'size');
sensor = sensorSet(sensor,'size',[rowcol(1)*2, rowcol(2)*4]);

% Set the CFA pattern accounting for the dual pixel architecture
sensor = sensorSet(sensor,'pattern',[2 2 1 1; 3 3 2 2]);

%% Render

piWrite(thisR);
[oi, result] = piRender(thisR,'render type','radiance');

% oiWindow(oi);
%% Compute the sensor data

% Notice that we get the spatial structure of the image right, even though
% the pixels are rectangular.
sensor = sensorCompute(sensor,oi);
sensor = sensorSet(sensor,'name','DPAF');
sensorWindow(sensor);

%%  Extract the left and right images from the dual pixel array

volts = sensorGet(sensor,'volts');
leftVolts = volts(1:end,1:2:end);
rightVolts = volts(1:end,2:2:end);

%% Create sensors for left and right image
leftSensor = sensorCreate;
leftSensor = sensorSet(leftSensor,'size',size(leftVolts));
leftSensor = sensorSet(leftSensor,'volts',leftVolts);
leftSensor = sensorSet(leftSensor,'name','left');

sensorWindow(leftSensor);

%%
rightSensor = sensorCreate;
rightSensor = sensorSet(rightSensor,'size',size(rightVolts));
rightSensor = sensorSet(rightSensor,'volts',rightVolts);
rightSensor = sensorSet(rightSensor,'name','right');
sensorWindow(rightSensor);

%%
ip = ipCreate;
ip = ipCompute(ip,sensor);
ipWindow(ip);

leftip = ipCreate;
leftip = ipCompute(leftip,leftSensor);
ipWindow(leftip);

rightip = ipCreate;
rightip = ipCompute(rightip,rightSensor);
ipWindow(rightip);

%% END

