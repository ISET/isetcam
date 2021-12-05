%%
% Demo some advantages of GPU rendering
% using our computational photograph (cp) framwork
% 
% Developed by David Cardinal, Stanford University, 2021
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
sensor = sensorFromFile('ar0132atSensorRGB'); 
% Cameras can eventually have more than one module (lens + sensor)
% but for now, we just create one using our sensor
ourCamera.cmodules(1) = cpCModule('sensor', sensor); 

scenePath = 'ChessSet';
sceneName = 'chessSet';

pbrtCPScene = cpScene('pbrt', 'scenePath', scenePath, 'sceneName', sceneName, ...
    'resolution', [512 512], ...
    'numRays', 128, 'sceneLuminance', 200);

% set the camera in motion
pbrtCPScene.cameraMotion = {{'unused', [1, 0, 0], [2, 2, 2]}};

finalImage = ourCamera.TakePicture(pbrtCPScene, 'Burst', 'numBurstFrames', 3, 'imageName','Burst with Camera Motion');
imtool(finalImage);

