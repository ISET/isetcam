%%
% Demo some advantages of GPU rendering
% using our computational photography (cp) framework
% uses a cpBurstCamera in 'video' mode to capture a series
% of 3D images generated using ISET3d-v4/pbrt-v4.
% 
% Camera and object motion are supported.
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
sensor = sensorCreate('imx363');
% for some reason we only make it 600 x 800 by default
%sensor = sensorSet(sensor,'pixelsize', ...
%    sensorGet(sensor,'pixel size')/1);
rez = 1024+512;
numFrames = 6;
rays = 12;
%sensor = sensorSet(sensor, 'fov',45);

ourRows = rez;
ourCols = floor((4/3)*rez); % for standard scenes, want 2:1 for Chess
sensor = sensorSet(sensor,'size',[ourRows ourCols]);

sensor = sensorSet(sensor,'noiseFlag', 0); % less noise

% Cameras can eventually have more than one module (lens + sensor)
% but for now, we just create one using our sensor
ourCamera.cmodules(1) = cpCModule('sensor', sensor); 

%%
%scenePath = 'bistro';
%sceneName = 'bistro';
%scenePath = 'landscape';
%sceneName = 'landscape';
% scenePath = 'ChessSet';
% sceneName = 'ChessSet';
scenePath = 'cornell_box';
sceneName = 'cornell_box';

pbrtCPScene = cpScene('pbrt', 'scenePath', scenePath, 'sceneName', sceneName, ...
    'resolution', [ourCols ourRows], ... % seems like pbrt is "backwards"?
    'sceneLuminance', 500, ...
    'numRays', rays);

% add the basic materials from our library
piMaterialsInsert(pbrtCPScene.thisR);

% put our scene in an interesting room
pbrtCPScene.thisR.set('lights','delete','all');
pbrtCPScene.thisR.set('skymap','room.exr','rotation val',{[90 0 1 0], [-90 1 0 0]});

lightName = 'from camera';
ourLight = piLightCreate(lightName,...
                        'type','distant',...
                        'cameracoordinate', true);

pbrtCPScene.thisR.set('light', 'add', ourLight);

if strcmp(scenePath, "cornell_box")
    % Add the Stanford bunny to the scene

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
    pbrtCPScene.thisR.set('asset','001_large_box_O','material name','glass');

    % change the bunny to a more interesting material
    pbrtCPScene.thisR.set('asset','001_Bunny_O', 'material name', 'mirror');
    %pbrtCPScene.thisR.set('asset','001_Bunny_O', 'material name', 'glass');
    pbrtCPScene.thisR.set('asset','Bunny_B', 'scale', 3);
    %pbrtCPScene.thisR.recipeSet('fov',60);

    % make sure we get enough bounces to show off materials
    pbrtCPScene.thisR.set('nbounces', 6);

elseif isequal(sceneName, 'ChessSet')
    % try moving a chess piece
    pbrtCPScene.objectMotion = {{'001_ChessSet_mesh_00005_O', ...
        [0, .1, 0], [0, 0, 0]}};
    pbrtCPScene.objectMotion = {{'001_ChessSet_mesh_00004_O', ...
        [0, 1, 0], [0, 0, 0]}};
    %     'lensFile','wide.77deg.4.38mm.json',...
    % set scene FOV to align with camera
    pbrtCPScene.thisR.recipeSet('fov',60);
end

% set the camera in motion
% settings for a nice slow 6fps video:
pbrtCPScene.cameraMotion = {{'unused', [.01, .01, 0], [-.33 -.33 0]}};
%pbrtCPScene.cameraMotion = {{'unused', [0, .01, 0], [-1, 0, 0]}};

videoFrames = ourCamera.TakePicture(pbrtCPScene, ...
    'Video', 'numVideoFrames', numFrames, 'imageName','Video with Camera Motion');

% optionally, take a peek
% imtool(videoFrames{1});
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



