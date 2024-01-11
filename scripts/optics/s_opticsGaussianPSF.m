%% The shift-invariant optics model for spatial blurring
%
% Local blur is often modeled as a *shift-invariant* blurring
% (convolution). The Gaussian point spread function (PSF) is also
% a common model for a first-order approximation.  It is not a
% good model, just a common model.
%
% This script illustrates the (oriented) Gaussian blur applied to
% a point array scene.
%
% See also:  siSynthetic
%
% Copyright ImagEval Consultants, LLC, 2006

%%
ieInit;

%% Create scene point array

% We do the calculation for only a few wavelengths, just for
% speed.
wave = (450:100:650);
nWaves = length(wave);

% Create scene
scene = sceneCreate('pointArray',128,32);
scene = sceneInterpolateW(scene,wave);
scene = sceneSet(scene,'hfov',1);
scene = sceneSet(scene,'name','psfPointArray');
ieAddObject(scene); sceneWindow;

%% Create optical image

oi = oiCreate;
oi = oiSet(oi,'wave',sceneGet(scene,'wave'));

%% Calculate Gaussian PSF

psfType = 'gaussian';

% We make an elongated Gaussian by setting the xyRatio to 3:1
xyRatio = 3*ones(1,nWaves);
waveSpread = wave/wave(1);
optics = siSynthetic(psfType,oi,waveSpread,xyRatio);

% Put optics back into oi and display "blurred" optical image
oi = oiSet(oi,'optics',optics);
oi = oiCompute(oi,scene);
ieAddObject(oi);
oiWindow;

%%
