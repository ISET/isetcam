%% Converting typical images to spectral radiance
%
% RGB data can be converted to scene spectral radiance, making it
% possible to many different scenes. Of course, RGB data do not
% have full spectral information, so ISET must convert the RGB
% data into spectral radiance data based on some principles. The
% computation we use is performed by an algorithm called by
% *sceneFroMFile* within the functon *vcReadImage*.
%
% Briefly, the algorithm is this:
%
%    1) We assume the RGB data will be displayed on a calibrated
%    monitor with a known spectral power distribution. The user
%    can specify the display, or a default is chosen.
%
%    2) The white (R=G=B at max) spectral power distribution of
%    the display is set to be the scene illuminant.
%
% If we make these assumptions, we can calculate reflectances of
% surfaces in the scene by dividing the scene radiance by the
% illuminant spd. These surface reflectances are plausible,
% as we discovered by many experiments.  See the script
% *s_sceneFromRGBvsMultispectral* to evaluate how well this
% method does.
%
% N.B. Once we have plausible scene reflectances we can render
% the scene under a different illuminant, say a daylight
% tungsten or many other examples.
%
% See also: s_sceneFromMultispectral, sceneFromFile,
%    displayCreate, ieXYZFromEnergy, chromaticityPlot,
%    ieDrawShape
%
% Copyright ImagEval, 2011

%%
ieInit
delay = 0.2;

%% Load display calibration data

displayCalFile = 'LCD-Apple.mat';
load(displayCalFile,'d'); dsp = d;
wave = displayGet(dsp,'wave');
spd = displayGet(dsp,'spd');

vcNewGraphWin; plot(wave,spd);
xlabel('Wave (nm)'); ylabel('Energy'); grid on
title('Spectral Power Distribution of Display Color Primaries');

%% Analyze the display properties: Chromaticity

d = displayCreate(displayCalFile);
whtSPD = displayGet(d,'white spd');
wave   = displayGet(d,'wave');
whiteXYZ = ieXYZFromEnergy(whtSPD',wave);

% Brings up the window
fig = chromaticityPlot(chromaticity(whiteXYZ));

%% Read in an rgb file and create calibrated display values

rgbFile = fullfile(isetRootPath,'data','images','rgb','eagle.jpg');
scene = sceneFromFile(rgbFile,'rgb',[],displayCalFile);

% Show the scene
sceneWindow(scene); pause(delay);

%% Change the illuminant to 6500 K

bb = blackbody(sceneGet(scene,'wave'),6500,'energy');
scene = sceneAdjustIlluminant(scene,bb);
sceneWindow(scene); pause(delay);

% Now the reflectances and the illuminant are plausible natural
% measurements.  Not great, but plausible.
% Here is how I selected the rectangle
%   [~, rect] = ieROISelect(scene);

% Here is the yellow beak region and its reflectance
rect = [144   198    27    18];
r = ieDrawShape(scene,'rectangle',rect);
set(r,'EdgeColor',[0 0 1]);
scenePlot(scene,'reflectance roi',rect);

%%