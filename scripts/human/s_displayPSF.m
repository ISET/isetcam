%% s_displayPSF
%
% Compute the point spread in each of the cone classes from each of the
% display primaries.
%
% This script may become the basis for calculating (efficiently) from a
% video
%
% Wandell, Copyright Imageval, LLC, 2015

ieInit

%%  Create a display and human optics (Marimont and Wandell model)

d = displayCreate;
oi = oiCreate('human');

%% We will loop on these when we are ready

coneType  = 3;  % K,L,M,S
pixelType = 2;  % R,G,B

%%  Make a point image on the display
r = 51;
img = zeros(r,r,3);
img((r+1)/2,(r+1)/2,pixelType) = 1;   

pointScene = sceneFromFile(img,'rgb',[],d);
% pointScene = sceneSet(pointScene,'distance',10);
ieAddObject(pointScene);
sceneWindow;

%%  Compute OI

oi = oiCompute(oi,pointScene);
ieAddObject(oi); oiWindow;

%%  Make a high resolution cone sampling array

% We will calculate the cone responses at 0.25um and then build the OTF
params.sz = [128,128];              % Square array
params.coneAperture = [.5 .5]*1e-6; % In meters

% Choose the cone type
dens = zeros(1,4);
dens(coneType) = 1;
params.rgbDensities = dens; % Empty, L,M,S

pixel = [];
sensor = sensorCreate('human',pixel,params);
sensor = sensorSetSizeToFOV(sensor,sceneGet(pointScene,'fov'));
sensor = sensorSet(sensor,'noise flag',0);

%
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor);
sensorWindow('scale',true);

%% Plot

v = sensorGet(sensor,'volts',coneType);  % Get the right cone type

vcNewGraphWin([],'tall');

subplot(2,1,1)
sz = sensorGet(sensor,'size');
v = reshape(v,sz(1),sz(2));
imagesc(v); axis image; colormap(gray)

subplot(2,1,2)
mesh(v); colormap(jet)

%%  Now show the white point spread, just as an illustration

img(51,51,:) = 1;   % Pixel color
pointScene = sceneFromFile(img,'rgb',[],d);
pointScene = sceneSet(pointScene,'distance',10);
oi     = oiCompute(oi,pointScene);
sensor = sensorCompute(sensor,oi);

ieAddObject(sensor);
sensorWindow('scale',true);

%% Plot

v = sensorGet(sensor,'volts',coneType);  % Get the right cone type

vcNewGraphWin([],'tall');

subplot(2,1,1)
sz = sensorGet(sensor,'size');
v = reshape(v,sz(1),sz(2));
imagesc(v); axis image; colormap(gray)

subplot(2,1,2)
mesh(v); colormap(jet)

m = getMiddleMatrix(v,127);

vcNewGraphWin; otf = psf2otf(m); mesh(fftshift(abs(otf)));

