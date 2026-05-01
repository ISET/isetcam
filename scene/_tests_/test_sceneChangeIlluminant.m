function tests = test_sceneChangeIlluminant()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
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
ieInit;
tolerance = 1e-6;
msg = 'sceneChangeIlluminant failure.';
%% Create a default scene

% sceneCreate creates a scene object. In this case, without any
% arguments, sceneCreate simulates a Macbeth ColorChecker
% uniformly illuminated with daylight 6500 (D65)

scene = sceneCreate;
% sceneWindow(scene); pause(delay);

% Plot the illuminant.
uData = scenePlot(scene,'illuminant photons');
assert(mean(uData.photons)/1.4089583e+16 - 1 < tolerance,msg);

%% Replace the current illuminant with a tungsten illuminant

% Read the Tungsten spectral power distribution.
wave  = sceneGet(scene,'wave');
TungstenEnergy = ieReadSpectra('Tungsten.mat',wave);

% The variable TungstenEnergy is a vector of illuminant energies
% at each wavelength.
scene = sceneAdjustIlluminant(scene,TungstenEnergy);
scene = sceneSet(scene,'illuminantComment','Tungsten illuminant');

% sceneWindow(scene); pause(delay);
uData = scenePlot(scene,'illuminant photons');
assert(mean(uData.photons(:))/1.4548346e+16 - 1 < tolerance,msg);

%% Read in a multispectral scene from data/images

sceneFile = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs.mat');
scene = sceneFromFile(sceneFile,'multispectral');
% sceneWindow(scene); pause(delay);
uData = scenePlot(scene,'illuminant energy');
assert(mean(double(uData.energy(:)))/ 0.001763837502128 - 1 < tolerance,msg);

%% Change the illuminant to equal energy

% This time, we send in the file name rather than the vector of
% illuminant energies
scene = sceneAdjustIlluminant(scene,'equalEnergy.mat');
% sceneWindow(scene); pause(delay);
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/1.180579424901852e+15 - 1 < tolerance,msg)
%% Convert the scene to the sunset color, Horizon_Gretag

scene = sceneAdjustIlluminant(scene,'illHorizon-20180220.mat');
% sceneWindow(scene); pause(delay);
photons = sceneGet(scene,'photons');
assert(mean(photons(:))/11.532888329013328e+15 - 1 < tolerance,msg)

%%
drawnow;

%%

end
