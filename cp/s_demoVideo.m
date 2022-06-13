%% S_DEMOVIDEO
%
% Demo some advantages of GPU rendering
% using our computational photography (cp) framework
% uses a cpBurstCamera in 'video' mode to capture a series
% of 3D images generated using ISET3d-v4/pbrt-v4.
% 
% Camera motion is supported on CPU and GPU.
% Currently Object Motion is only supported on CPU (PBRT-v4 limitation)
% 
% Developed by David Cardinal, Stanford University, 2021-2022.
%

ieInit();
% some timing code, just to see how fast we run...
setpref('ISET', 'benchmarkstart', cputime); 
setpref('ISET', 'tStart', tic);

% cpBurstCamera is a sub-class of cpCamera that implements simple HDR and Burst
% capture and processing
ourCamera = cpBurstCamera(); 

% TODO: Better "meta-data" parameters here, that correlate scene size,
%       Camera motion, Object Motion, and Frame Rate
%
% We'll use a pre-defined sensor for our Camera Module, and let it use
% default optics for now. We can then assign the module to our camera:
sensor = sensorCreate('imx363');

% The sensor comes in with a small default resolution, and in any case
% well want to decide on one for ourselves:
nativeSensorResolution = 2048; % about real life
aspectRatio = 4/3;  % Set to desired ratio

% Specify the number of frames for our video
numFrames = 16; % Total number of frames to render
videoFPS = 8; % How many frames per second to encode

% Rays per pixel (more is slower, but less noisy)
nativeRaysPerPixel =  512;

% Fast Preview Factor
fastPreview = 1; % 16 ; % multiplierfor optional faster rendering
raysPerPixel = floor(nativeRaysPerPixel/fastPreview);

ourRows = floor(nativeSensorResolution / fastPreview);
ourCols = floor(aspectRatio * ourRows); 
sensor = sensorSet(sensor,'size',[ourRows ourCols]);

sensor = sensorSet(sensor,'noiseFlag', 0); % 0 is less noise

% Make the pixels bigger, but keep the sensor the same size
% This is useful for previewing more quickly:
nativePSize = pixelGet(sensor.pixel,'pixel width');
previewPSize = nativePSize * fastPreview;
sensor.pixel = pixelSet(sensor.pixel,'sizesamefillfactor',[previewPSize previewPSize]);


% Cameras can eventually have more than one module (lens + sensor)
% but for now, we just create one using our sensor
ourCamera.cmodules(1) = cpCModule('sensor', sensor); 

%%
%{
scenePath = 'ChessSet';
sceneName = 'ChessSet';
sceneWidth = 1; % rough width of scene in meters
sceneHeight = .5; % rough height of scene in meters
desiredXRotation = 20; % how many degrees do we want to rotate down
desiredYRotation = 90; % how many degrees do we want to rotate left
xGravity = 1; % Inverse of how many scene widths to move horizontally
yGravity = 4; % Inverse of how many scene widths to move vertically

%}

scenePath = 'cornell_box';
sceneName = 'cornell_box';
sceneWidth = 2; % rough width of scene in meters
sceneHeight = 1; % rough height of scene in meters
desiredXRotation = 55; % how many degrees do we want to rotate down
desiredYRotation = 150; % how many degrees do we want to rotate left
xGravity = .4; % Inverse of how many scene widths to move horizontally
yGravity = .9; % Inverse of how many scene widths to move vertically

pbrtCPScene = cpScene('pbrt', 'scenePath', scenePath, 'sceneName', sceneName, ...
    'resolution', [ourCols ourRows], ... 
    'sceneLuminance', 500, ...
    'numRays', raysPerPixel);

% add the basic materials from our library
piMaterialsInsert(pbrtCPScene.thisR);

% clear out any default lights
pbrtCPScene.thisR = piLightDelete(pbrtCPScene.thisR, 'all');

% put our scene in an interesting room
pbrtCPScene.thisR.set('skymap', 'room.exr', 'rotation val', [-90 180 0]);

lightName = 'from camera';
spectrumScale = 3; lightSpectrum = 'equalEnergy';
ourLight = piLightCreate(lightName,...
                           'type', 'distant',...
                           'specscale float', spectrumScale,...
                           'spd spectrum', lightSpectrum,...
                           'cameracoordinate', true);

pbrtCPScene.thisR.set('light', ourLight, 'add');

%{
% use smaller film if we are previewing
% but it doesn't actually seem to make rendering faster?
if fastPreview > 1
    pbrtCPScene.thisR.set('filmresolution',pbrtCPScene.thisR.get('filmresolution')\2);
end
%}


% try leaving out the bunny
if strcmp(scenePath, "cornell_box")

    % If we have the Cornell box, add the Stanford bunny to the scene
    bunny = piAssetLoad('bunny.mat');
    bunny.name = 'Bunny';
    if isfield(bunny,'thisR')
        pbrtCPScene.thisR = piRecipeMerge(pbrtCPScene.thisR, bunny.thisR);
    else
        piAssetAdd(pbrtCPScene.thisR, '0001ID_root', bunny);
    end
    pbrtCPScene.thisR.set('asset', 'Bunny_B', 'world position',...
        [0 0 1.3]);
    %take the back wall off for fun
    pbrtCPScene.thisR.set('asset','003_cornell_box_O','delete');
    
    % hide the box so we can see through
    pbrtCPScene.thisR.set('asset','001_large_box_O','material name','brickwall001');

    % change the bunny to a more interesting material
    %pbrtCPScene.thisR.set('asset','001_Bunny_O', 'material name', 'mirror');
    pbrtCPScene.thisR.set('asset','001_Bunny_O', 'material name', 'glass');
    pbrtCPScene.thisR.set('asset','Bunny_B', 'scale', 3);
    %pbrtCPScene.thisR.recipeSet('fov',60);

    % make sure we get enough bounces to show off materials
    pbrtCPScene.thisR.set('nbounces', 5); % up from 5 in case that's why our background is off

elseif isequal(sceneName, 'ChessSet')
    % try moving a chess piece
    % NOTE: This is currently ignored when rendering on GPU
    pbrtCPScene.objectMotion = {{'001_ChessSet_mesh_00005_O', ...
        [0, .1, 0], [0, 0, 0]}};
    pbrtCPScene.objectMotion = {{'001_ChessSet_mesh_00004_O', ...
        [0, 1, 0], [0, 0, 0]}};

    % set scene FOV to align with camera
    % Not clear this does what we want?
    %pbrtCPScene.thisR.recipeSet('fov',90);
end


% set the camera in motion, using meters per second per axis
% 'unused', then translate, then rotate
% Z is into scene, Y is up, X is right
translateZPerFrame = 0; 
translateYPerFrame = (sceneHeight / numFrames) / yGravity;
translateXPerFrame = (sceneWidth / numFrames) / xGravity;

% X-axis is 'vertical' rotation, Y-axis is 'horizontal'
rotateXPerFrame =  -1 * (desiredXRotation / numFrames);
rotateYPerFrame = -1 * (desiredYRotation / numFrames);

pbrtCPScene.cameraMotion = {{'unused', ...
    [translateXPerFrame, translateYPerFrame, translateZPerFrame], ...
    [rotateXPerFrame, rotateYPerFrame, 0]}};

videoFrames = ourCamera.TakePicture(pbrtCPScene, ...
    'Video', 'numVideoFrames', numFrames, 'imageName','Video with Camera Motion');

% optionally, take a peek
imtool(videoFrames{4});
if isunix
    demoVideo = VideoWriter('cpDemo', 'Motion JPEG AVI');
else
    % H.264 only works on Windows and Mac
    demoVideo = VideoWriter('cpDemo', 'MPEG-4');
end
demoVideo.FrameRate = videoFPS;
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



