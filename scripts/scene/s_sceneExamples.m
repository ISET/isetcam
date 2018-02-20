%% Show examples of built-in scenes
%
% ISET includes many *built-in scenes* that are used for testing
% the properties of *optics* and *sensors*.  This script shows
% how to create those scenes.
%
% Many of built-in scenes can be created using parameters that
% are set when you call the *sceneCreate* function.  This script
% illustrates how to set thses parameters.  You can learn how to
% create these scenes by using
% 
%   doc('sceneCreate')
%
% See also:  s_sceneDemo, sceneCreate, s_sceneFromMultispectral,
%            s_sceneFromRGB
%
% Copyright ImagEval Consultants, LLC, 2003.

%%
ieInit;

%% Rings and Rays
radF = 24; imSize = 512;
scene = sceneCreate('rings rays');
ieAddObject(scene); sceneWindow;

%% Frequency orientation - useful for analyzing demosaicking
parms.angles = linspace(0,pi/2,5);
parms.freqs  =  [1,2,4,8,16];
parms.blockSize = 64;
parms.contrast  = .8;
scene = sceneCreate('frequency orientation',parms);
ieAddObject(scene); sceneWindow;

%% Harmonic
parms.freq = 1; parms.contrast = 1; parms.ph = 0;
parms.ang= 0; parms.row = 64; parms.col = 64; parms.GaborFlag=0;
[scene,parms] = sceneCreate('harmonic',parms);
ieAddObject(scene); sceneWindow;

%% Checkerboard
period = 16; spacing = 8; spectralType = 'ep';
scene = sceneCreate('checkerboard',period,spacing,spectralType);
ieAddObject(scene); sceneWindow;

%% Single line
imageSize = 128; 
scene = sceneCreate('lined65',imageSize);
ieAddObject(scene); sceneWindow;

%% Slanted Bar
imageSize = 128;
edgeSlope = 1.3;
scene = sceneCreate('slantedBar',imageSize,edgeSlope);
ieAddObject(scene); sceneWindow;

%% Grid Lines
imageSize = 128;
pixelsBetweenLines = 16;
scene = sceneCreate('grid lines',imageSize,pixelsBetweenLines);
ieAddObject(scene); sceneWindow;

%% Point Array
imageSize = 256;
pixelsBetweenPoints = 32;
scene = sceneCreate('point array',imageSize,pixelsBetweenPoints);
ieAddObject(scene); sceneWindow;

%% Macbeth Color Checker
patchSizePixels = 16;
wave = (380:5:720);
scene = sceneCreate('macbeth tungsten',patchSizePixels,wave,'bit depth',64);
ieAddObject(scene); sceneWindow;

%% Natural-100 Reflectance Chart
scene = sceneCreate('reflectance chart');
ieAddObject(scene);
sceneWindow;

%% Macbeth Color Checker
patchSizePixels = 16;
wave = (380:5:720);
scene = sceneCreate('macbeth tungsten',patchSizePixels,wave,'bit depth',64);
ieAddObject(scene); sceneWindow;

%% Uniform Field
sz = 128;
wavelength = 380:10:720;
scene = sceneCreate('uniformEESpecify',sz,wavelength);
ieAddObject(scene); sceneWindow;

%% Lstar target, centered around 50 cd/m2
barSize = [80 10]; nBars = 20; dEStep = 1;
scene = sceneCreate('lstar',barSize,nBars,dEStep);
ieAddObject(scene); sceneWindow;

%% Exponential ramp
sz = 256; dRange = 1024;
scene = sceneCreate('exponential intensity ramp',sz,dRange);
ieAddObject(scene); sceneWindow;

%% 
