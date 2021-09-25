%% Introduction to ISET display structure.
%
% Create a default display object.
% Set and get the display object parameters and features.
%
% Copyright Imageval LLC, 2015

%%
ieInit;

%% Create a display

% Create a default display
% Other displays
%  d = displayCreate('LCD-Apple');
%  d = displayCreate('OLED-Sony');
%  d = displayCreate('CRT-Dell');
d = displayCreate('OLED-Samsung');

%% Show default image and GUI

% Show display structure in a GUI window
ieAddObject(d); displayWindow;

%% Get and Set methods

% Example display parameters
%   displayGet(d, 'name');
%   displayGet(d, 'gamma table');
%   displayGet(d, 'white xyz');
%   displayGet(d, 'primaries xyz');
%   displayGet(d, 'rgb2xyz');
%
% For the full list type - doc('displayGet') or doc('displaySet');
d = displaySet(d, 'dpi', 150);
displayGet(d,'dpi')

%% Plot for display basics

% Plot for display primaries spd, gamma table, etc.
% More plot options can be found in displayPlot
displayPlot(d, 'spd');   % spectral power distribution
displayPlot(d, 'gamma'); % gamma table
displayPlot(d, 'gamut');

%% Create scene from image and display

% Create scene by specifying image on display
I = im2double(imread('eagle.jpg'));
scene = sceneFromFile(I, 'rgb', [], d);  % Note display included
ieAddObject(scene); sceneWindow;

% Note that by default the spectral power distribution of the scene is
% based on the primaries of the display.  Also, notice that the
% illuminant is equal to the white point of the display
scenePlot(scene,'illuminant photons');

%% Adjust illuminant and radiance

% This preserves reflectance but changes the illuminant and radiance.
% Rendered image changes appearance.
scene2 = sceneAdjustIlluminant(scene,'Fluorescent.mat');
scene2 = sceneSet(scene2,'name','fluorescent');
sceneWindow(scene2);

%% Adjust the illuminant and preserve the scene radiance

% This changes the reflectance.  Radiance is unchanged, so the
% rendered image is unchanged
wave = sceneGet(scene,'wave');
ill = illuminantCreate('d50',wave);
scene3 = sceneSet(scene,'illuminant',ill);
scene3 = sceneSet(scene3,'name','d50');
sceneWindow(scene3);

%%
