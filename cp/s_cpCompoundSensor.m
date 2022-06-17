% Support for sensors with multiple pixel types / exposure times
%
% D. Cardinal, Stanford Universidy, June, 2022
%
% Initial target is Samsung Corner Pixel Automotive technology
%

ieInit();
% some timing code, just to see how fast we run...
setpref('ISET', 'benchmarkstart', cputime);
setpref('ISET', 'tStart', tic);

% cpBurstCamera is a sub-class of cpCamera that implements simple HDR and Burst
% capture and processing
ourCamera = cpBurstCamera();

% We'll use a pre-defined sensor for our Camera Module, and let it use
% default optics for now. We can then assign the module to our camera:
%sensor = sensorCreate('imx363'); % pixel sensor

% For Corner Pixel, we want a more Auto-friendly sensor
% with larger main pixels
sensor = sensorFromFile('ar0132atSensorRGB.mat');

% for an auto sensor we need different optics
oi = oiCreate();
oi = oiSet(oi, 'optics', opticsCreate('standard (1-inch)'));

% Cameras can eventually have more than one module (lens + sensor)
% but for now, we just create one using our sensor
ourCamera.cmodules(1) = cpCModule('sensor', sensor,'oi',oi);


ourSceneFile = fullfile('StuffedAnimals_tungsten-hdrs.mat');
extremeSceneFile = fullfile('Feng_Office-hdrs.mat');
hdrScene = cpScene('iset scene files', 'isetSceneFileNames', ourSceneFile);
extremeScene = cpScene('iset scene files', 'isetSceneFileNames', extremeSceneFile);

% Experiment with a pbrt scene:
scenePath = 'ChessSet';
sceneName = 'chessSet';
numRays = 64; filmResolution = 512;
pbrtScene = cpScene('pbrt', 'scenePath', scenePath, 'sceneName', sceneName, ...
    'resolution', [filmResolution filmResolution], ...
    'numRays', numRays);
% put our scene in an interesting room
pbrtScene.thisR.set('skymap', 'room.exr', 'rotation val', [-90 0 0]);

%{
    alternate for a more extreme case
    showScene = extremeScene;
    expTimes = [1 1 1];
%}

% Choose a sample scene to show
showScene = extremeScene;
autoISETImage = ourCamera.TakePicture(showScene, 'Auto',...
    'imageName','ISET Scene in Auto Mode');
imtool(autoISETImage); 

insensorIP = true;
% Use a traditional HDR bracket
hdrISETImage = ourCamera.TakePicture(showScene, 'HDR',...
    'insensorIP',insensorIP,'numHDRFrames',3,...
    'imageName',sprintf('HDR Mode with %d frames',3));

baseExposure = .1;
% Corner Pixel Simulation
% right now we manually set exposure times for the Manual
% mode, so those need to be tweaked as needed
cornerFillFactors = [.9 .1];
cornerExpTimes = [baseExposure baseExposure];
cornerToneMap = 'largest';
cornerISETImage = ourCamera.TakePicture(showScene, 'Manual',...
    'insensorIP',insensorIP,'numHDRFrames',numel(cornerFillFactors),...
    'expTimes', cornerExpTimes, 'fillFactors', cornerFillFactors, ...
    'tonemap',cornerToneMap, ...
    'imageName','Corner Pixel Simulation');

% Do a manual multi-exposure to mimic the Corner Pixel case
bracketFillFactors = [1 1 1];
bracketExpTimes = [baseExposure/9 baseExposure/3 baseExposure];
bracketTonemap = 'longest';
bracketISETImage = ourCamera.TakePicture(showScene, 'Manual',...
    'insensorIP',insensorIP,'numHDRFrames',numel(bracketExpTimes),...
    'expTimes',bracketExpTimes, 'fillFactors',bracketFillFactors, ...
    'tonemap', bracketTonemap, ...
    'imageName','Manual Bracketing');

caption = sprintf(['Bracket: Fill= %s, %s, %s Exp= %s, %s, %s, Tone: %s\n', ...
    ' Corner: Fill= %s, %s & Exp= %s, %s, Tone: %s\n'], ...
    string(bracketFillFactors), string(bracketExpTimes), bracketTonemap, ...
    string(cornerFillFactors), string(cornerExpTimes), cornerToneMap);
    
cpCompareImages(bracketISETImage,cornerISETImage,caption);

%{
    imtool(brackISETImage);
    imtool(cornerISETImage);
%}
