%% Create a spatial resolution slanted bar target
%
% *Slanted bar* scenes are used measuring the *ISO 12233* standard
% for spatial resolution (spatial frequency responce). This
% function and related ones are embedded into the interface and
% illustrated in other scripts.
%
%   sceneCreate('slantedBar',imageSize,edgeSlope, fieldOfView, illPhotons);
%
% See also:  ieISO12233, ISOFindSlantedBar, sceneCreate, metricsCamera
%
% Copyright ImagEval Consultants, LLC, 2010.

%%
ieInit

%% Slanted bar parameters

sz          = 256;
barSlope    = 2.6;
fieldOfView = 2;
meanL = 100;

%% An example slanted bar

% The default slanted bar is created with an illuminant of equal photons
% across wavelengths
scene = sceneCreate('slantedBar', sz, barSlope, fieldOfView);
scene = sceneAdjustLuminance(scene,meanL);

% Have a look at the image in the scene Window
sceneWindow(scene);

% Here is the scene energy
scenePlot(scene,'illuminant energy roi')

%% Change the slanted bar to a D65 illuminant, rather than equal energy

scene = sceneAdjustIlluminant(scene,'D65.mat');

% Have a look
sceneWindow(scene);
scenePlot(scene,'illuminant energy roi')

%% Create slanted bar with another slope

barSlope    = 3.6;
sz          = 128;
fieldOfView = 0.5;

scene = sceneCreate('slantedBar', sz, barSlope, fieldOfView);
sceneWindow(scene);

%%
