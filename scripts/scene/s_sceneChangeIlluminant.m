%% Change the illuminant spectral power distribution of a scene
%
% ISET lets you specify any spectral power distribution as a
% scene illuminant, and the data/lights directory includes a
% large number of standard lights, including fluorescents,
% tungsten, LED, daylights, and blackbody.
%
% The *scene window* lets you select a new scene illuminant from
% the pulldown menu.
%
%   Edit | Adjust SPD | Change illuminant
%
% Illuminants can vary across the scene. 
%
% See also: sceneAdjustIlluminant, s_Illuminant, s_sceneIlluminantSpace
%
% Copyright ImagEval Consultants, LLC, 2010.

%%
ieInit

%% Create a default scene
 
% sceneCreate creates a scene object. In this case, without any
% arguments, sceneCreate simulates a Macbeth ColorChecker
% uniformly illuminated with daylight 6500 (D65)

scene = sceneCreate;
ieAddObject(scene); sceneWindow;

% Plot the illuminant.
scenePlot(scene,'illuminant photons');


%% Replace the current illuminant with a tungsten illuminant

% Read the Tungsten spectral power distribution.
wave  = sceneGet(scene,'wave');
TungstenEnergy = ieReadSpectra('Tungsten.mat',wave);

% The variable TungstenEnergy is a vector of illuminant energies
% at each wavelength.
scene = sceneAdjustIlluminant(scene,TungstenEnergy);
scene = sceneSet(scene,'illuminantComment','Tungsten illuminant');

sceneWindow(scene);
scenePlot(scene,'illuminant photons roi');

%% Read in a multispectral scene from data/images

sceneFile = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs.mat');
scene = sceneFromFile(sceneFile,'multispectral');
ieAddObject(scene); sceneWindow; 
scenePlot(scene,'illuminant energy');

%% Change the illuminant to equal energy

% This time, we send in the file name rather than the vector of
% illuminant energies
scene = sceneAdjustIlluminant(scene,'equalEnergy.mat');
ieAddObject(scene); sceneWindow; % display sceneWindow

%% Convert the scene to the sunset color, Horizon_Gretag

scene = sceneAdjustIlluminant(scene,'Horizon_Gretag.mat');
ieAddObject(scene); sceneWindow; 


%%
