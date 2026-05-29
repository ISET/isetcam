function tests = test_sceneChangeIlluminant()
tests = functiontests(localfunctions);
end

function testMain(~)
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

function testPreserveMeanAndReflectance(~)

ieInit;

tolerance = 1e-4;
roi = [9 9 24 24];

scene = sceneCreate;
baselineMeanL = sceneGet(scene, 'mean luminance');
baselineReflectance = sceneGet(scene, 'roi mean photons', roi) ./ sceneGet(scene, 'roi mean illuminant photons', roi);
baselineIlluminant = mean(sceneGet(scene, 'illuminant photons'), 'all');

wave = sceneGet(scene, 'wave');
tungstenEnergy = ieReadSpectra('Tungsten.mat', wave);
scene = sceneAdjustIlluminant(scene, tungstenEnergy);

adjustedMeanL = sceneGet(scene, 'mean luminance');
adjustedReflectance = sceneGet(scene, 'roi mean photons', roi) ./ sceneGet(scene, 'roi mean illuminant photons', roi);
adjustedIlluminant = mean(sceneGet(scene, 'illuminant photons'), 'all');

assert(abs(adjustedMeanL - baselineMeanL) < tolerance * baselineMeanL, ...
    'sceneAdjustIlluminant should preserve mean luminance by default.');
assert(max(abs(baselineReflectance - adjustedReflectance)) / max(abs(baselineReflectance)) < 1e-5, ...
    'sceneAdjustIlluminant should preserve reflectance.');
assert(abs(adjustedIlluminant - baselineIlluminant) > tolerance * baselineIlluminant, ...
    'Illuminant photons should change after illuminant replacement.');

end

function testStructInputMatchesVectorInput(~)

ieInit;

tolerance = 1e-6;
scene = sceneCreate;
wave = sceneGet(scene, 'wave');
tungstenEnergy = ieReadSpectra('Tungsten.mat', wave);

illuminant = illuminantCreate('d65', wave);
illuminant = illuminantSet(illuminant, 'energy', tungstenEnergy);

sceneFromVector = sceneAdjustIlluminant(scene, tungstenEnergy);
sceneFromStruct = sceneAdjustIlluminant(scene, illuminant);

vectorPhotons = sceneGet(sceneFromVector, 'photons');
structPhotons = sceneGet(sceneFromStruct, 'photons');
vectorIlluminant = sceneGet(sceneFromVector, 'illuminant photons');
structIlluminant = sceneGet(sceneFromStruct, 'illuminant photons');

assert(max(abs(vectorPhotons(:) - structPhotons(:))) / mean(vectorPhotons(:)) < tolerance, ...
    'Struct and vector illuminant inputs should produce the same photons.');
assert(max(abs(vectorIlluminant(:) - structIlluminant(:))) / mean(vectorIlluminant(:)) < tolerance, ...
    'Struct and vector illuminant inputs should produce the same illuminant.');

end

function testPreserveMeanFalseChangesMeanLuminance(~)

ieInit;

scene = sceneCreate;
baselineMeanL = sceneGet(scene, 'mean luminance');
wave = sceneGet(scene, 'wave');
tungstenEnergy = ieReadSpectra('Tungsten.mat', wave);

preservedScene = sceneAdjustIlluminant(scene, tungstenEnergy, true);
unpreservedScene = sceneAdjustIlluminant(scene, tungstenEnergy, false);

preservedMeanL = sceneGet(preservedScene, 'mean luminance');
unpreservedMeanL = sceneGet(unpreservedScene, 'mean luminance');

assert(abs(preservedMeanL - baselineMeanL) < 1e-4 * baselineMeanL, ...
    'Preserve-mean mode should preserve mean luminance.');
assert(abs(unpreservedMeanL - baselineMeanL) > 1e-3 * baselineMeanL, ...
    'preserveMean=false should allow mean luminance to change.');

end
