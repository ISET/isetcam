%% Calculating the defocused image (spectral irradiance) of a scene 
%
% This script shows how to compute the defocus for an image in a single
% depth plane given the *defocus* (blur) in diopters.
%
% Defocus can be caused when the sensor plane differs from the correct
% focal distance from the image plane. This script also shows how to
% calculate the defocus in diopters given the distance of the sensor plane
% from the perfect focal distance (lensmaker's equation).
%
% In a general 3D scene, some points may be in focus while others are not.
%
% See also: opticsDefocusCore, opticsBuild2Dotf
%
% Copyright ImagEval Consultants, LLC, 2013

%%
ieInit

% I like showing the waitbar when the computations take more than a second
% ieSessionSet('wait bar','on');

%% Create a test scene

% This is a spectral radiance scene
% We image that it sweeps out 5 deg of visual angle
wave = 400:10:700;
fullFileName = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs');
scene = sceneFromFile(fullFileName,'multispectral',[],[],wave);
scene = sceneSet(scene,'fov',5);

% This is the spatial resolution of the scene
maxSF = sceneGet(scene,'max freq res','cpd');
nSteps = min(ceil(maxSF),70);              % Round up, but don't go too high.
sampleSF = linspace(0, maxSF, nSteps);     % cyc/deg

% Add the scene to the database and show it
ieAddObject(scene); sceneWindow;

%% Adjust illuminant color

% I prefer this rendering.  Why not enjoy life?
scene = sceneAdjustIlluminant(scene,'D65.mat');
ieAddObject(scene); sceneWindow;

%% Standard shift invariant optics
% We are assuming a diffraction limited lens with some defocus.
%
oi     = oiCreate;
optics = oiGet(oi,'optics');
optics = opticsSet(optics,'model','shift invariant');
wave   = opticsGet(optics,'wave');

%% Create the optical transfer function (OTF) for the specified defocus 

% Initialize the defocus for each wavelength
defocus = zeros(size(wave));
D = 5;                     % Defocus
defocus = defocus + D;     % In units of diopters

% Create the defocused otf 
[otf, sampleSFmm] = opticsDefocusCore(optics,sampleSF,defocus);

% First create the optics with this defocus OTF
optics = opticsBuild2Dotf(optics,otf,sampleSFmm);

oi = oiSet(oi,'optics',optics);
oi = oiCompute(oi,scene);
oi = oiSet(oi,'name',sprintf('%.1f-defocus',D));
ieAddObject(oi); oiWindow;

%% Perfect focus, and then two cases where the distance is wrong

% Here is the perfect image with no defocus.
defocus = zeros(size(wave));
D = 0;
defocus = defocus + D;
[otf, sampleSFmm] = opticsDefocusCore(optics,sampleSF,defocus);

optics = opticsBuild2Dotf(optics,otf,sampleSFmm);

oi = oiSet(oi,'optics',optics);
oi = oiCompute(oi,scene);
oi = oiSet(oi,'name',sprintf('%.1f-defocus',D));

v1 = ieAddObject(oi); oiWindow;
%% Calculate the consequences for an image that is 10 um off

% Correct focal length
fLength = opticsGet(optics,'focal length');
lensPower = opticsGet(optics,'diopters');

% Suppose the image focal length misses by this much 10 microns
deltaDistance = 10e-6;

% The effective power of a lens imaging at that distance is
actualPower = 1 / (fLength - deltaDistance);

% Correction needed - which is also the amount of defocus
D = actualPower - lensPower;
defocus = zeros(size(wave));
defocus = defocus + D;     % In units of diopters

% Create the defocused otf 
[otf, sampleSFmm] = opticsDefocusCore(optics,sampleSF,defocus);
optics = opticsBuild2Dotf(optics,otf,sampleSFmm);

% Compute and name and view
oi = oiSet(oi,'optics',optics);
oi = oiCompute(oi,scene);
oi = oiSet(oi,'name',sprintf('%.1f-defocus',D));

v2 = ieAddObject(oi); oiWindow;

%% Again, but for for an image that is 40 um off

% Correct focal length
fLength = opticsGet(optics,'focal length');
lensPower = opticsGet(optics,'diopters');

% Suppose the image focal length misses by this much 40 microns
deltaDistance = 40e-6;

% The effective power of a lens imaging at that distance is
actualPower = 1 / (fLength - deltaDistance);

% Correction needed - which is also the amount of defocus
D = actualPower - lensPower;
defocus = zeros(size(wave));
defocus = defocus + D;     % In units of diopters

% Create the defocused otf 
[otf, sampleSFmm] = opticsDefocusCore(optics,sampleSF,defocus);
optics = opticsBuild2Dotf(optics,otf,sampleSFmm);

% Compute and name and view
oi = oiSet(oi,'optics',optics);
oi = oiCompute(oi,scene);
oi = oiSet(oi,'name',sprintf('%.1f-defocus',D));

v3 = ieAddObject(oi); oiWindow;


%% Show the three optical image results in three windows
imageMultiview('oi',[v1,v2,v3],true);

% Put back the wait bar status
ieSessionSet('wait bar','off');

%% 