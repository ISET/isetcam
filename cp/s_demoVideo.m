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
rez = 1024;
sensor = sensorSet(sensor,'size',[rez 2*rez]);
% 
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

rays = 256; %128;
pbrtCPScene = cpScene('pbrt', 'scenePath', scenePath, 'sceneName', sceneName, ...
    'resolution', [2*rez rez], ...
    'sceneLuminance', 500, ...
    'numRays', rays);

%{
thisR = piRecipeDefault('scene name','cornell_box');
thisR = piMaterialsInsert(thisR);
thisR.set('nbounces',6);
thisR.set('film resolution',[640 640]);
    thisR.set('rays per pixel',128);

thisR.set('lights','delete','all');
[~, roomLight] = thisR.set('skymap','room.exr');
    
    %
    % infinite, distant, area light, ...
    %
    % thisR.set('skymap','skycommand',param)
    % thisR.set('skymap','add','room.exr')
    % thisR.set('skymap','room.exr','delete');
    % thisR.set('skymap','room.exr','rotate',val)
    %
       
thisR.set('asset','003_cornell_box_O','delete');
piWRS(thisR);

thisR.set('lights','rotate',roomLight.name,[40 -25 0]);
r = thisR.get('lights','skymap','rotation');
r{2}
piWRS(thisR);

thisR.set('material','cbox_Material','reflectance val',[0.3 0.3 1]);

thisR.set('asset','001_large_box_O','material name','glass');
thisR.set('asset','003_cornell_box_O','delete');
        

piWRS(thisR);
   
thisR.set('lights','rotation',roomLight.name,[0 45 0 0]);

piWRS(thisR);

piWRS(thisR);
    
% We should be able to just look at the environment light.
 
%}
    
if strcmp(scenePath, "cornell_box")
    % Add the Stanford bunny to the scene
    bunny = piAssetLoad('bunny.mat');
    bunny.name = 'Bunny';
    % Zheng: there is an easy way to add bunny in the scene:
    if isfield(bunny,'thisR')
        pbrtCPScene.thisR = piRecipeMerge(pbrtCPScene.thisR, bunny.thisR);
    else
        piAssetAdd(pbrtCPScene.thisR, '0001ID_root', bunny);
    end
    % Zheng: This is another useful feature to place bunny at a targeted
    % position.
    pbrtCPScene.thisR.set('asset', 'Bunny_B', 'world position',...
        [0 0.125 0]);
elseif isequal(sceneName, 'ChessSet')
    % try moving a chess piece
    pbrtCPScene.objectMotion = {{'001_ChessSet_mesh_00005_O', ...
        [0, .1, 0], [0, 0, 0]}};
    pbrtCPScene.objectMotion = {{'001_ChessSet_mesh_00004_O', ...
        [0, 1, 0], [0, 0, 0]}};
end


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
lightName = 'on the chess set';
ourLight = piLightCreate(lightName,...
                        'type','distant',...
                        'spd spectrum','equalEnergy',...
                        'cameracoordinate', true, ...
                        'scale',[4.0 4.0 4.0]);

pbrtCPScene.thisR.set('light', 'add', ourLight);

% set the camera in motion
% settings for a nice slow 6fps video:
pbrtCPScene.cameraMotion = {{'unused', [.007, .005, 0], [-.45, -.45, 0]}};
%pbrtCPScene.cameraMotion = {{'unused', [0, .01, 0], [-1, 0, 0]}};




videoFrames = ourCamera.TakePicture(pbrtCPScene, ...
    'Video', 'numVideoFrames', 12, 'imageName','Video with Camera Motion');
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



