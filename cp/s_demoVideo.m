%%
% Demo some advantages of GPU rendering
% using our computational photography (cp) framework
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
%sensor = sensorFromFile('ar0132atSensorRGB'); 
sensor = sensorCreate('imx363');
% for some reason we only make it 600 x 800 by default
%sensor = sensorSet(sensor,'pixelsize', ...
%    sensorGet(sensor,'pixel size')/1);
rez = 128;
sensor = sensorSet(sensor,'size',[rez 2*rez]);
% 
sensor = sensorSet(sensor,'noiseFlag', 0); % less noise

% Cameras can eventually have more than one module (lens + sensor)
% but for now, we just create one using our sensor
ourCamera.cmodules(1) = cpCModule('sensor', sensor); 

%scenePath = 'bistro';
%sceneName = 'bistro';
%scenePath = 'landscape';
%sceneName = 'landscape';
scenePath = 'ChessSet';
sceneName = 'ChessSet';
%scenePath = 'cornell_box';
%sceneName = 'cornell_box';

rays = 16; %128;
pbrtCPScene = cpScene('pbrt', 'scenePath', scenePath, 'sceneName', sceneName, ...
    'resolution', [2*rez rez], ...
    'numRays', rays);
%     'sceneLuminance', 200, ...
%     'lensFile','wide.77deg.4.38mm.json',...
% set scene FOV to align with camera
pbrtCPScene.thisR.recipeSet('fov',60);

% try deleting the default point light
% but some scenes have environmental lights that work?
% AttributeBegin
%     Rotate -120 1 0 0
%     Rotate 150 0 0 1
%     LightSource "infinite" "string filename" "lightmap_v4.exr"
% AttributeEnd
%piLightDelete(pbrtCPScene.thisR, 'all'); 
lightName = 'We can only hope';
ourLight = piLightCreate(lightName,...
                        'type','distant',...
                        'spd spectrum','equalEnergy',...
                        'cameracoordinate', true, ...
                        'specscale',2.0);

pbrtCPScene.thisR.set('light', 'add', ourLight);

% set the camera in motion
% settings for a nice slow 6fps video:
pbrtCPScene.cameraMotion = {{'unused', [007, .005, 0], [-.4, -.4, 0]}};
%pbrtCPScene.cameraMotion = {{'unused', [0, .01, 0], [-1, 0, 0]}};


videoFrames = ourCamera.TakePicture(pbrtCPScene, ...
    'Video', 'numVideoFrames', 2, 'imageName','Video with Camera Motion');
%imtool(videoFrames{1});
if isunix
    demoVideo = VideoWriter('cpDemo', 'Motion JPEG AVI');
else
    % H.264 only works on Windows and Mac
    demoVideo = VideoWriter('cpDemo', 'MPEG-4');
end
demoVideo.FrameRate = 2;
demoVideo.Quality = 99;
open(demoVideo);
for ii = 2:numel(videoFrames)
    writeVideo(demoVideo,videoFrames{ii});
end
close (demoVideo);

% timing code
tTotal = toc(getpref('ISET','tStart'));
afterTime = cputime;
beforeTime = getpref('ISET', 'benchmarkstart', 0);
glData = opengl('data');
disp(strcat("Local cpCam ran  on: ", glData.Vendor, " ", glData.Renderer, "with driver version: ", glData.Version)); 
disp(strcat("Local cpCam ran  in: ", string(afterTime - beforeTime), " seconds of CPU time."));
disp(strcat("Total cpCam ran  in: ", string(tTotal), " total seconds."));



