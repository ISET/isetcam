% sample script to assemble a pbrt test scene for object and camera motion.
%
% Feb, 2021, David Cardinal
% Feb, 2022, updated to iset3d-v4, David Cardindl
%
% We load the "bare" Cornell box, and then add the Stanford
% bunny and the MCC chart (and AF target?) so that we have a full test
% scene.
%

%{
% recipe test, since on some systems there are errant 0 depth pixels
thisR = piRecipeDefault('scene name', 'CornellBoxReference');
thisR.set('spatial resolution',[640 640]);
piWrite(thisR);
ourScene = piRender(thisR);
min(min(ourScene.depthMap))
ieNewGraphWin; mesh(ourScene.depthMap);
ieNewGraphWin; imagesc(ourScene.depthMap);
%}

%%
ieInit();
filmResolution = 256;
numRays = 64;
sceneLuminance = 100;
ourCamera = cpBurstCamera();
sensor = sensorCreate('imx363');
sensor = sensorSet(sensor,'size',[3000,4000]);
ourCamera.cmodules(1) = cpCModule('sensor', sensor);

%% scene -- just a wrapper for piRecipeDefault when created:
simpleScene = cpScene('pbrt', 'scenePath', 'CornellBoxReference', ...
    'sceneName', 'CornellBoxReference', ...
    'resolution', [filmResolution filmResolution], ...
    'numRays', numRays, ...
    'sceneLuminance', sceneLuminance);

% Add the Stanford bunny to the scene
bunny = piAssetLoad('bunny.mat');
% An easy way to add bunny in the scene:
simpleScene.thisR = piRecipeMerge(simpleScene.thisR, bunny.thisR, 'node name',bunny.mergeNode);
% This is another useful feature to place bunny at a targeted position.
simpleScene.thisR.set('asset', 'Bunny_B', 'world position', [0 0.125 0]);

% Add a Macbeth chart
macbeth = piAssetLoad('macbeth.mat');
% Scale its size to be good for the Cornell Box & Move to center
thisName = macbeth.thisR.get('object names no id');
sz = macbeth.thisR.get('asset',thisName{1},'size');
macbeth.thisR.set('asset',thisName{1},'scale',[0.1 0.1 0.1] ./ sz);
simpleScene.thisR = piRecipeMerge(simpleScene.thisR, macbeth.thisR, 'node name',macbeth.mergeNode);
simpleScene.thisR.set('asset', thisName{1}, 'world position', [0 .05 0]);

% Add a light
lightName = 'from camera';
ourLight = piLightCreate(lightName,...
                        'type','distant',...
                        'cameracoordinate', true);

simpleScene.thisR.set('light', ourLight, 'add');

%%
rendered = piWRS(simpleScene.thisR);

% We get a tiny slice of the image, but if we try to change the sensor to
% match the 50 degree FOV, it scales by adding pixels and becomes massive
% resolution
if isequal(rendered.type,'scene')
    rendered = oiCompute(rendered,oiCreate());
end
sensorRender = sensorCompute(sensor, rendered);
sensorWindow(sensorRender);

% ------------------- SPARE STUFF BELOW ---------------------------------
%ourCamera.cmodules(1).sensor = ...
%    sensorSet(ourCamera.cmodules(1).sensor, ...
%    'size', [filmResolution, filmResolution]);

% Look at the original scene by showing our camera and then clicking
% "Preview" to get a rendering.
% cpCameraWindow(ourCamera, simpleScene);

% for focus stacking let's make our lens wide-open and
% longer focal length so we get optical blur
%ourCamera.cmodules(1).oi = oiSet(ourCamera.cmodules(1).oi,'optics focallength', .120);
%ourCamera.cmodules(1).oi = oiSet(ourCamera.cmodules(1).oi,'optics fnumber',1.2);

%thisR.assets.show;
% Optionally add some motion to the bunny
% simpleScene.objectMotion = {{'Bunny_O', [1 0 0], [0 0 0]}};

% Take a look if we want
%{
scene = piRender(thisR);
sceneWindow(scene);
%}

%cpCameraWindow(ourCamera, simpleScene);

% TODO Next:
% Add MCC
% Add AF chart if there is an asset for it
% Give the resulting scene to our camera & try again.

%%
