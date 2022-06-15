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

%sensorSetSizeToFOV()

extremeScene = cpScene('iset scene files', 'isetSceneFileNames', extremeSceneFile);

%{
    alternate for a more extreme case
    showScene = extremeScene;
    expTimes = [1 1 1];
%}

% Relatively simple HDR example
% or more extreme example
showScene = hdrScene;
expTimes = [.1 .1 .1];
autoISETImage = ourCamera.TakePicture(showScene, 'Auto',...
    'imageName','ISET Scene in Auto Mode');
imtool(autoISETImage); 

insensorIP = true;
hdrISETImage = ourCamera.TakePicture(showScene, 'HDR',...
    'insensorIP',insensorIP,'numHDRFrames',3,...
    'imageName','ISET Scene in HDR Mode');

% right now we manually set exposure times for the Manual
% mode, so those need to be tweaked as needed
fillFactors = [.9 .1];
expTimes = [.1 .12];
manualISETImage = ourCamera.TakePicture(showScene, 'Manual',...
    'insensorIP',insensorIP,'numHDRFrames',numel(fillFactors),...
    'expTimes', expTimes, 'fillFactors', fillFactors, ...
    'imageName','ISET Scene in Manual Mode');
ipWindow(manualISETImage);

if insensorIP
    % we're still in gamma=1 space here, so need to use
    % ipWindow to get an accurate look
    ipWindow(hdrISETImage);
    ipWindow(manualISETImage);
else
    imtool(hdrISETImage);
    imtool(manualISETImage);
end