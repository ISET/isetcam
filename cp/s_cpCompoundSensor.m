% Support for sensors with multiple pixel types / exposure times
%
% D. Cardinal, Stanford University, June, 2022
%
% Initial target is Samsung Corner Pixel Automotive technology
%
% In this script we allow comparisons between traditional HDR bracketing
% (an equal number of stops above and below a base value), manual
% bracketing with arbitrary exposures, and a simulated "corner pixel"
% sensor that records a single image but uses a compound pixel that has two
% different photosites with different properties.
% 
% In this case we simulate the compound pixel by allowing multiple
% exposures with different fill factors, that are treated as a single
% exposure. However we do allow for the case where the various sub-pixels
% vary in their exposure time. This is true of the Samsung design, for
% example, as a way of handling LED flicker.
%

ieInit();

% cpBurstCamera is a sub-class of cpCamera that implements simple HDR and Burst
% capture and processing
ourCamera = cpBurstCamera();

% For Corner Pixel, we want an Auto-friendly sensor
% with larger main pixels than, for example, a smartphone
sensor = sensorFromFile('ar0132atSensorRGB.mat');

% for a larger sensor we need different optics
oi = oiCreate();
oi = oiSet(oi, 'optics', opticsCreate('standard (1-inch)'));

% Cameras can eventually have more than one module (lens + sensor)
% but for now, we just create one using our sensor and optics
ourCamera.cmodules(1) = cpCModule('sensor', sensor,'oi',oi);

% We provide several example iset scenes from which to choose
ourSceneFile = fullfile('StuffedAnimals_tungsten-hdrs.mat');
extremeSceneFile = fullfile('Feng_Office-hdrs.mat');
hdrScene = cpScene('iset scene files', 'isetSceneFileNames', ourSceneFile);
extremeScene = cpScene('iset scene files', 'isetSceneFileNames', extremeSceneFile);

% We can also experiment with a 3D pbrt scene:
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

% Choose one of our example scenes to use
showScene = extremeScene;
autoISETImage = ourCamera.TakePicture(showScene, 'Auto',...
    'imageName','ISET Scene in Auto Mode');
imtool(autoISETImage); 

insensorIP = true;
% Use a traditional HDR bracket (-1, 0, +1)
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
% Quick code to help analyze the resulting images
    imtool(bracketISETImage);
    imtool(cornerISETImage);
%}
