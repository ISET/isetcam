function tests = test_roiSet()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% Validate the sceneSet for 'roi photons' and 'roi energy'
%
% We extract a region's data and copy it to a new location
%
% Wandell, October 2019

%%
ieInit;

%% Simple test scene

scene = sceneCreate;


%% Pull out the photons from the white patch
roiRect = [1    50    14    14];
newPhotons = sceneGet(scene,'roi photons',roiRect);

%% Place the white patch photons into a new location

shiftedRect = [20 30 14 14];
shiftedScene = sceneSet(scene,'roi photons',newPhotons,shiftedRect);
testCase.verifyEqual(sceneGet(shiftedScene,'roi photons',shiftedRect),newPhotons,'RelTol',single(1e-6));

%% Now make sure it works with roiLocs format

% This will darken the patch
roiLocs = ieRect2Locs(shiftedRect);

shiftedSceneGray = sceneSet(scene,'roi photons',newPhotons/3,roiLocs);
testCase.verifyEqual(sceneGet(shiftedSceneGray,'roi photons',roiLocs),newPhotons/3,'RelTol',single(1e-6));

%%  Now with energy

newEnergy = sceneGet(scene,'roi energy',roiRect);

%% Set the white patch into a new location

shiftedRect = [40 30 14 14];
shiftedScene = sceneSet(scene,'roi energy',newEnergy,shiftedRect);
testCase.verifyEqual(sceneGet(shiftedScene,'roi energy',shiftedRect),newEnergy,'RelTol',single(1e-6));

%% Now make sure it works with roiLocs

% This will darken the patch
roiLocs = ieRect2Locs(shiftedRect);
shiftedSceneGray = sceneSet(scene,'roi energy',newEnergy/3,roiLocs);
testCase.verifyEqual(sceneGet(shiftedSceneGray,'roi energy',roiLocs),newEnergy/3,'RelTol',single(1e-6));

%% END

end
