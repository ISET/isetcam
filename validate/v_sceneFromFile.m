%% Validation script for sceneFromFile
%
% Makes and deletes a small test scene in the local directory
%
% BW

%%
ieInit;

% Use the local directory that is not included in the git repository.
cd(fullfile(isetRootPath,'local'));

%% Create and read a scene variable from the file

% This is the new feature
scene = sceneCreate;
save('testS','scene');

s = sceneFromFile('testS');
assert(isequal(s,scene));  % Should be the same

%%  Read in a mat multispectral file

% Check that the old stuff worked
fName = 'StuffedAnimals_tungsten-hdrs.mat';
scene = sceneFromFile(fName,'multispectral');
ieAddObject(scene); sceneWindow;

%% Create a file from RGB data
RGB = ieClip(255*rand(10,10,3),0,255);
scene = sceneFromFile(RGB,'rgb',100,'lcdExample');
ieAddObject(scene); sceneWindow;

%% Now try sceneToFile with the scene data

% This tests whether the new 'fov' and 'dist' read/write works
vExplained = sceneToFile('testS2',scene);
scene2 = sceneFromFile('testS2','multispectral');
ieAddObject(scene2); sceneWindow;

%% Now try on a jpg image
fullFileName = which('eagle.jpg');
scene = sceneFromFile(fullFileName,'rgb',100,'lcdExample');
ieAddObject(scene); sceneWindow;
assert(abs(scene.wAngular - 15.5233) < 1e-3);

%% Clean up
if exist('testS.mat','file'), delete('testS.mat'); end

%%
