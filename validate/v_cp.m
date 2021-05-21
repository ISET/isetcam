% Validation script for the simple (non-3D) part of our Computational
% Imaging (ci) classes

%%
ieInit

%% Init an arbitrary scene
aScene = sceneFromFile('StuffedAnimals_tungsten-hdrs.mat','multispectral');

% Make a burst version
aScenes = [aScene aScene aScene];
expTimes = [.1 .1 .1];   % Seconds

%% create computational versions of those scenes

cScenes = cpScene('iset scenes', 'isetScenes', aScenes);
cScene  = cpScene('iset scenes', 'isetScenes', aScene);

%%
ourCamera = cpCamera();

%%
ourCamera.TakePicture(cScene, 'Auto');

%%
ourCamera.TakePicture(cScenes, 'Burst', 'expTimes', expTimes);

%%