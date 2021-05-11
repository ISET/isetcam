%% Validate the sceneSet for 'roi photons' and 'roi energy'
%
% We extract a region's data and copy it to a new location
%
% Wandell, October 2019

%%
ieInit;

%% Simple test scene

scene = sceneCreate;
sceneWindow(scene);

%% Pull out the photons from the white patch
roiRect = [1, 50, 14, 14];
newPhotons = sceneGet(scene, 'roi photons', roiRect);

%% Place the white patch photons into a new location

shiftedRect = [20, 30, 14, 14];
shiftedScene = sceneSet(scene, 'roi photons', newPhotons, shiftedRect);
sceneWindow(shiftedScene);

%% Now make sure it works with roiLocs format

% This will darken the patch
roiLocs = ieRect2Locs(shiftedRect);

shiftedSceneGray = sceneSet(scene, 'roi photons', newPhotons/3, roiLocs);
sceneWindow(shiftedSceneGray);

%%  Now with energy

newEnergy = sceneGet(scene, 'roi energy', roiRect);

%% Set the white patch into a new location

shiftedRect = [40, 30, 14, 14];
shiftedScene = sceneSet(scene, 'roi energy', newEnergy, shiftedRect);
sceneWindow(shiftedScene);

%% Now make sure it works with roiLocs

% This will darken the patch
roiLocs = ieRect2Locs(shiftedRect);
shiftedSceneGray = sceneSet(scene, 'roi energy', newEnergy/3, roiLocs);
sceneWindow(shiftedSceneGray);

%% END
