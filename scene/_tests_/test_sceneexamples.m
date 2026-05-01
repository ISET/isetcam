function tests = test_sceneexamples()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
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

tolerance = 1e-5;

fprintf('Validating mean photons for multiple scenes ... ');

%% Rings and Rays
radF = 24; imSize = 512;
scene = sceneCreate('rings rays');
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/3.8433e+15 - 1 < tolerance);

%% Frequency orientation - useful for analyzing demosaicking
parms.angles = linspace(0,pi/2,5);
parms.freqs  =  [1,2,4,8,16];
parms.blockSize = 64;
parms.contrast  = .8;
scene = sceneCreate('frequency orientation',parms);
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/3.8433e+15 - 1 < tolerance);

%% Harmonic

parms.freq = 1; parms.contrast = 1; parms.ph = 0;
parms.ang= 0; parms.row = 64; parms.col = 64; parms.GaborFlag=0;
[scene,parms] = sceneCreate('harmonic',parms);
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/3.8433e+15 - 1 < tolerance);

%% Harmonic

parms.freq = 1; parms.contrast = 1; parms.ph = 0;
parms.ang= 0; parms.row = 64; parms.col = 64; parms.GaborFlag=0;
[scene,parms] = sceneCreate('harmonic',parms);
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/3.8433e+15 - 1 < tolerance);

%% Checkerboard
period = 16; spacing = 8; spectralType = 'ep';
scene = sceneCreate('checkerboard',period,spacing,spectralType);
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/3.8433e+15 - 1 < tolerance);

%% Single line
imageSize = [128,128];
scene = sceneCreate('lined65',imageSize);
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/3.8433e+15 - 1 < tolerance);

%% Slanted Bar
imageSize = 128;
edgeSlope = 1.3;
scene = sceneCreate('slantedBar',imageSize,edgeSlope);
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/3.8433e+15 - 1 < tolerance);

%% Grid Lines
imageSize = 128;
pixelsBetweenLines = 16;
scene = sceneCreate('grid lines',imageSize,pixelsBetweenLines);
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/3.8433e+15 - 1 < tolerance);

%% Point Array
imageSize = 256;
pixelsBetweenPoints = 32;
scene = sceneCreate('point array',imageSize,pixelsBetweenPoints);
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/3.8433e+15 - 1 < tolerance);

%% Macbeth Color Checker
patchSizePixels = 16;
wave = (380:5:720);
scene = sceneCreate('macbeth tungsten',patchSizePixels,wave);
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/4.5393e+15 - 1 < tolerance);

%% Natural-100 Reflectance Chart
scene = sceneCreate('reflectance chart');
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/4.0174e+15 - 1 < tolerance);

%% Macbeth Color Checker
patchSizePixels = 16;
wave = (380:5:720);
scene = sceneCreate('macbeth tungsten',patchSizePixels,wave);
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/4.5393e+15 - 1 < tolerance);

%% Uniform Field
sz = 128;
wavelength = 380:10:720;
scene = sceneCreate('uniformEESpecify',sz,wavelength);
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/3.7940e+15 - 1 < tolerance);

%% Lstar target, centered around 50 cd/m2
barSize = [80 10]; nBars = 20; dEStep = 1;
scene = sceneCreate('lstar',barSize,nBars,dEStep);
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/3.8433e+15 - 1 < tolerance);

%% Exponential ramp
sz = 256; dRange = 1024;
scene = sceneCreate('exponential intensity ramp',sz,dRange);
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/3.8433e+15 - 1 < tolerance);

fprintf('done\n');
%% END

end
