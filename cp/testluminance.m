ieInit
scenePath = 'Cornell_BoxBunnyChart';
sceneName = 'cornell box bunny chart';

ourCamera = ciBurstCamera();

if ~piDockerExists, piDockerConfig; end

thisR = piRecipeDefault('scene name', sceneName);
val = recipeSet(thisR, 'filmresolution', [128, 128]);
val = recipeSet(thisR, 'rays per pixel', 32);

ourScene = ciScene('pbrt', 'scenePath', scenePath, 'sceneName', sceneName);

autoImage = ourCamera.TakePicture(ourScene, 'Auto', ...
    'imageName', 'Auto Mode');
ieAddObject(autoImage);

thisR = piRecipeDefault('scene name', sceneName);
val = recipeSet(thisR, 'filmresolution', [128, 128]);
val = recipeSet(thisR, 'rays per pixel', 32);

ourScene = ciScene('pbrt', 'scenePath', scenePath, 'sceneName', sceneName);

autoImage = ourCamera.TakePicture(ourScene, 'Auto', ...
    'imageName', 'Auto Mode', 'reRender', false);
ieAddObject(autoImage);
