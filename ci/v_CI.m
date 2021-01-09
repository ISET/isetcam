% Validation script for the simple (non-3D) part of our Computational
% Imaging (ci) classes

ieInit

% Init an arbitrary scene
aScene = sceneFromFile('StuffedAnimals_tungsten-hdrs.mat','multispectral');

% Make a burst version
aScenes = [aScene aScene aScene];
expTimes = [.1 .1 .1];

% create computational versions of those s
cScenes = ciScene('iset scenes', aScenes);
cScene = ciScene(aScene);
    
ourCamera = ciCamera();

ourCamera.takePicture(aScene, 'Auto');

ourCamera.takePicture(aScenes, 'Burst');

