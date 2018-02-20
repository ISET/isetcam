%% Validation script for sceneFromFile
%
% Makes a small test scene in the local directory
% 

ieInit;

% I have a local directory where I test stuff that is not included in the
% git repository.
cd(fullfile(isetRootPath,'local'));

%% Create and read a scene variable from the file

% This is the new feature
scene = sceneCreate;
save('testS','scene');

s = sceneFromFile('testS');
isequal(s,scene)  % Should be the same

%%  Read in a mat multispectral file

% Check that the old stuff worked
fName = 'StuffedAnimals_tungsten-hdrs.mat';
scene = sceneFromFile(fName,'multispectral');
ieAddObject(scene); sceneWindow;

%% Create a file from RGB data
d = displayCreate;

RGB = ieClip(255*rand(10,10,3),0,255);
scene = sceneFromFile(RGB,'rgb');
ieAddObject(scene); sceneWindow;

%% Now try sceneToFile with the scene data

% This tests whether the new 'fov' and 'dist' read/write works
vExplained = sceneToFile('testS2',scene);
scene2 = sceneFromFile('testS2','multispectral');
ieAddObject(scene2); sceneWindow;

%% Now try on a jpg image
fullFileName = which('eagle.jpg');
scene = sceneFromFile(fullFileName,'rgb',[],d);
ieAddObject(scene); sceneWindow;
%%
