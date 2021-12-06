%%
% Demo some advantages of GPU rendering
% using our computational photograph (cp) framework
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
    'numRays', 128, 'sceneLuminance', 400);

% set the camera in motion
pbrtCPScene.cameraMotion = {{'unused', [0, .01, 0], [-1, 0, 0]}};

videoFrames = ourCamera.TakePicture(pbrtCPScene, ...
    'Video', 'numVideoFrames', 2, 'imageName','Video with Camera Motion');
%imtool(videoFrames{1});
chessVideo = VideoWriter('ChessSet.avi', 'MPEG-4');
chessVideo.FrameRate = 5;
open(chessVideo);
for ii = 1:numel(videoFrames)
    writeVideo(chessVideo,videoFrames{ii});
end
close (chessVideo);

% timing code
tTotal = toc(getpref('ISET','tStart'));
afterTime = cputime;
beforeTime = getpref('ISET', 'benchmarkstart', 0);
glData = opengl('data');
disp(strcat("Local cpCam ran  on: ", glData.Vendor, " ", glData.Renderer, "with driver version: ", glData.Version)); 
disp(strcat("Local cpCam ran  in: ", string(afterTime - beforeTime), " seconds of CPU time."));
disp(strcat("Total cpCam ran  in: ", string(tTotal), " total seconds."));



