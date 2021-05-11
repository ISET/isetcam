%% The ray trace optical model illustrated
%
% The *ray trace* model for image formation uses information
% about the main lens to calculate
%
%  * geometric distortion
%  * relative illumination
%  * field-height and wavelength-dependent PSF
%
% This script illustrates the ray trace calculation, bringing up
% an array of figures that show different aspects of the
% calculation.
%
% The example is based on an aspherical, 2mm lens whose point
% spread functions were computed in *Zemax* .
%
% For comparison,  the optical image is also computed using
% diffraction limited methods (shift-invariant).  The f# and
% focal length of the diffraction model are set equal to those of
% the ray trace lens.
%
% See also:  rtGeometry, rtPrecomputePSF, rtPrecomputePSFApply
%
% Copyright ImagEval, LLC, 2005

%%
ieInit

%% Set up a wide angle scene for the wide angle lens below
scene = sceneCreate('gridlines', [384, 384], 48);
scene = sceneInterpolateW(scene, (550:100:650)); % Small wavelength sample
scene = sceneSet(scene, 'hfov', 45);
scene = sceneSet(scene, 'name', 'rtDemo-Large-grid');

% Show the grid line scene
ieAddObject(scene);
sceneWindow;

%% Import wide angle lens optics.

% Set up default optical image
oi = oiCreate;

% Load in the wide angle lens optics file created by Zemax (zm)
opticsFileName = fullfile(isetRootPath, 'data', 'optics', 'zmWideAngle.mat');
load(opticsFileName, 'optics');

% Set the oi with the optics loaded from the file
oi = oiSet(oi, 'optics', optics);

% Retrieve it and print its name to verify and inform user
fprintf('Ray trace optics: %s\n', opticsGet(optics, 'lensFile'));

%% Set up diffraction limited parameters to match the ray trace numbers

% Now, match the scene properties
oi = oiSet(oi, 'wangular', sceneGet(scene, 'wangular'));
oi = oiSet(oi, 'wavelength', sceneGet(scene, 'wavelength'));

% Match the scene distance and the rt distance.  They are both essentially
% infinite.
scene = sceneSet(scene, 'distance', 2); % Two meters - essentially inf
oi = oiSet(oi, 'optics rtObjectDistance', sceneGet(scene, 'distance', 'mm'));

%% Compute the distortion and show it in the OI

% We calculate in the order of (a) Distortion, (b) Relative
% illumination, and then (c) OTF blurring The function rtGeometry
% calculates the distortion and relative illumination at the same time.
oi = rtGeometry(oi, scene);

% Copy the resulting data into the optical image structure
oi = oiSet(oi, 'name', 'Geometry only');
ieAddObject(oi);
oiWindow;

%% Precompute the PSF
%
angStep = 20; % Very coarse for speed
svPSF = rtPrecomputePSF(oi, angStep);
oi = oiSet(oi, 'psfStruct', svPSF);

% Apply
oi = rtPrecomputePSFApply(oi, angStep);
oi = oiSet(oi, 'name', 'Stepwise-RT');
ieAddObject(oi);
oiWindow;

%% We choose ray trace by setting the optics method
%
oi = oiSet(oi, 'optics model', 'ray trace');

% Compute the RT
oi = oiCompute(scene, oi);
oi = oiSet(oi, 'name', 'Automated ray trace');

% Have a look - barrell distortion and all
ieAddObject(oi);
oiWindow;

% Here is a horizontal line of illuminance
rtData = oiPlot(oi, 'illuminance hline', [1, 64]);

%% Compute using the diffraction-limited method
%
oiDL = oiSet(oi, 'optics model', 'diffraction limited');
optics = oiGet(oiDL, 'optics');

% Set the diffraction limited f# from the ray trace values
fNumber = opticsGet(optics, 'rt fnumber');
optics = opticsSet(optics, 'fnumber', fNumber);
oiDL = oiSet(oiDL, 'optics', optics);

% Now set the method to diffraction limited and compute
oiDL = oiSet(oiDL, 'name', 'DL method');
oiDL = oiCompute(scene, oiDL);

% No barrel distortion, less blurring
ieAddObject(oiDL);
oiWindow;

% Here is a horizontal line of illuminance
dlData = oiPlot(oiDL, 'illuminance hline', [1, 64]);

%% Make the FOV smaller to show the ray trace blurring

% The first calculation was spatially coarse, and inappropriate
% for a geometric calculation such as barrel distortion.
%
% Here, we make the scene smaller and recalculate. With this
% field of view there is no noticeable distortion, but the sample
% spacing is much finer so we can see the various point spread
% functions
%
% At this resolution, the calculation takes a little while.

sceneSmall = sceneSet(scene, 'name', 'rt-Small-Grid');
sceneSmall = sceneSet(sceneSmall, 'fov', 20);

% Ray trace calculation with distortion and shift-variant blurring
oi = oiCompute(sceneSmall, oi);
oi = oiSet(oi, 'name', 'rt-Small-RT');
ieAddObject(oi);
oiWindow;

%% Equivalent diffraction limited

% There is no distortion computed and the scene is small
% This calculation is pretty quick.
oiDL = oiCompute(sceneSmall, oiDL);
oiDL = oiSet(oiDL, 'name', 'rt-Small-DL');
ieAddObject(oiDL);
oiWindow;

%%
