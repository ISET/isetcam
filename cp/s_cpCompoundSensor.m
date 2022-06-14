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
sensor = sensorCreate('imx363'); % pixel sensor
% Cameras can eventually have more than one module (lens + sensor)
% but for now, we just create one using our sensor
ourCamera.cmodules(1) = cpCModule('sensor', sensor);

ourSceneFile = fullfile('StuffedAnimals_tungsten-hdrs.mat');
sceneLuminance = 500;
isetCIScene = cpScene('iset scene files', 'isetSceneFileNames', ourSceneFile, ...
    'sceneLuminance', sceneLuminance);

autoISETImage = ourCamera.TakePicture(isetCIScene, 'Auto',...
    'imageName','ISET Scene in Auto Mode');
imtool(autoISETImage); 

insensorIP = true;
hdrISETImage = ourCamera.TakePicture(isetCIScene, 'HDR',...
    'insensorIP',insensorIP,'numHDRFrames',5,...
    'imageName','ISET Scene in HDR Mode');
if insensorIP
    ipWindow(hdrISETImage);
else
    imtool(hdrISETImage);
end