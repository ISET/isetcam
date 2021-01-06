scenePath = 'Cornell_BoxBunnyChart';
sceneName = 'cornell box bunny chart';

if ~piDockerExists, piDockerConfig; end

thisR = piRecipeDefault('scene name', sceneName);
val = recipeSet(thisR,'filmresolution', [128 128]);
val = recipeSet(thisR,'rays per pixel',32);

% Add an equal energy distant light for uniform lighting
spectrumScale = .1;
lightSpectrum = 'equalEnergy';
thisR = piLightAdd(thisR,...
    'type','distant',...
    'light spectrum',lightSpectrum,...
    'spectrum scale', spectrumScale,... % also tried with no space, fwiw
    'cameracoordinate', true);
[sceneObject, results] = piRender(thisR, 'render type', 'radiance', 'mean luminance', 1, 'scalePupilArea', true);
sprintf("Light is %f, Scene luminance is: %f", spectrumScale, sceneGet(sceneObject, 'mean luminance'))

clear all
scenePath = 'Cornell_BoxBunnyChart';
sceneName = 'cornell box bunny chart';

if ~piDockerExists, piDockerConfig; end

thisR = piRecipeDefault('scene name', sceneName);
val = recipeSet(thisR,'filmresolution', [128 128]);
val = recipeSet(thisR,'rays per pixel',32);

% Add an equal energy distant light for uniform lighting
spectrumScale = 1000000;
lightSpectrum = 'equalEnergy';

thisR = piLightAdd(thisR,...
    'type','distant',...
    'light spectrum',lightSpectrum,...
    'spectrum scale', spectrumScale,...
    'cameracoordinate', true);
[sceneObject, results] = piRender(thisR, 'render type', 'radiance', 'mean luminance', 10000);
sprintf("Light is %f, Scene luminance is: %f", spectrumScale, sceneGet(sceneObject, 'mean luminance'))
