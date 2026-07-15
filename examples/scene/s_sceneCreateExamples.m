%% Show examples of built-in scenes
%
% ISET includes many *built-in scenes* used to test and demonstrate
% optics and sensor behavior. This script shows how to create a representative
% subset with common parameter settings.
%
% Learn more with:
%
%   doc('sceneCreate')
%
% See also: s_sceneDemo, sceneCreate, s_sceneFromMultispectral,
%           s_sceneFromRGB
%
% Copyright ImagEval Consultants, LLC, 2003.

%%
ieInit;

%% Rings and rays
scene = sceneCreate('rings rays');
sceneWindow(scene); pause(0.1);

%% Frequency orientation
% Useful for analyzing orientation/frequency behavior and demosaicking.
parms.angles = linspace(0,pi/2,5);
parms.freqs = [1 2 4 8 16];
parms.blockSize = 64;
parms.contrast = 0.8;
scene = sceneCreate('frequency orientation',parms);
sceneWindow(scene); pause(0.1);

%% Harmonic
parms.freq = 1;
parms.contrast = 1;
parms.ph = 0;
parms.ang = 0;
parms.row = 64;
parms.col = 64;
parms.GaborFlag = 0;
[scene,~] = sceneCreate('harmonic',parms);
sceneWindow(scene); pause(0.1);

%% Checkerboard
period = 16;
spacing = 8;
spectralType = 'ep';
scene = sceneCreate('checkerboard',period,spacing,spectralType);
sceneWindow(scene); pause(0.1);

%% Single line
imageSize = 128;
scene = sceneCreate('lined65',imageSize);
sceneWindow(scene); pause(0.1);

%% Slanted bar
edgeSlope = 1.3;
scene = sceneCreate('slantedBar',imageSize,edgeSlope);
sceneWindow(scene); pause(0.1);

%% Grid lines
pixelsBetweenLines = 16;
scene = sceneCreate('grid lines',imageSize,pixelsBetweenLines);
sceneWindow(scene); pause(0.1);

%% Point array
imageSize = 256;
pixelsBetweenPoints = 32;
scene = sceneCreate('point array',imageSize,pixelsBetweenPoints);
sceneWindow(scene); pause(0.1);

%% Macbeth color checker
patchSizePixels = 16;
wave = 380:5:720;
scene = sceneCreate('macbeth tungsten',patchSizePixels,wave);
sceneWindow(scene); pause(0.1);

%% Natural-100 reflectance chart
scene = sceneCreate('reflectance chart');
sceneWindow(scene); pause(0.1);

%% Uniform field
sz = 128;
wavelength = 380:10:720;
scene = sceneCreate('uniformEESpecify',sz,wavelength);
sceneWindow(scene); pause(0.1);

%% Lstar target, centered around 50 cd/m2
barSize = [80 10];
nBars = 20;
dEStep = 1;
scene = sceneCreate('lstar',barSize,nBars,dEStep);
sceneWindow(scene); pause(0.1);

%% Exponential ramp
sz = 256;
dRange = 1024;
scene = sceneCreate('exponential intensity ramp',sz,dRange);
sceneWindow(scene); pause(0.1);

%%