%% cpFacesHeads
%
% 
% Use Brian's Heads with Face Detector
% D.Cardinal, Stanford, 2022
%
%%
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
% Load the canonical pbrt head (until we get some others!)
thisR = piRecipeDefault('scene name','head');

thisR.set('rays per pixel',512);
% we probably don't need much resolution, given the low-rez of most 
% face feature algorithms
thisR.set('film resolution',[320 320]*2);
thisR.set('n bounces',5);

% Set up a list of scenes that we render for later evaluation
scenes = {};

%% This renders
[scene, results] = piWRS(thisR);
scenes = [scenes, scene];
%%
% Because it is a full 3D head, we can rotate and re-render
thisR.set('asset','001_head_O','rotate',[5 20 0]);
[scene, results] = piWRS(thisR);
scenes = [scenes, scene];

%% Change the camera position
oFrom = thisR.get('from');
oTo = thisR.get('to');
oUp = thisR.get('up');

thisR.set('object distance', 1.3);

% relight the scene with a variety of skymaps
thisR.set('lights','all','delete');

skymaps = {'sky-brightfences', ...
    'glacier_latlong.exr', ...
    'sky-sun-clouds.exr', ...
    'sky-rainbow.exr', ...
    'ext_LateAfternoon_Mountains_CSP.exr', ...
    'sky-cathedral_interior'
    }

for ii = 1:numel(skymaps)
    thisR.set('skymap',skymaps{ii});
    [scene, results] = piWRS(thisR);
    scenes = [scenes, scene];
end

%{
% This adds a small xyz coordinate legend if we want it
coord = piAssetLoad('coordinate');
thisR = piRecipeMerge(thisR,coord.thisR,'node name',coord.mergeNode,'object instance', false);
thisR.set('asset','mergeNode_B','world position',thisR.get('from') + -0.5*thisR.get('fromto'));
thisR.set('asset','mergeNode_B','scale',0.2);

piWRS(thisR);
%}

% Move closer? Ask Brian:)
thisR.set('from',oFrom);
thisR.set('object distance', 1.5);
thisR.set('from',oFrom + [0 0 0.1]);
[scene, results] = piWRS(thisR);
scenes = [scenes, scene];

%%  Materials

% Use a nice skylight
thisR.set('lights','all','delete');
thisR.set('skymap','sky-brightfences.exr');

% Add our list of materials
piMaterialsInsert(thisR);

% look to see which objects we have, to assign materials
%thisR.show('objects')

% should be a .get :(
materialMap = thisR.materials.list;
materials = values(materialMap);

% Loop through our material list
for ii = 1:numel(materials)
    thisR.set('asset','001_head_O','material name',materials{ii}.name);
    [scene, results] = piWRS(thisR);
    scenes = [scenes, scene];
end

%% Now Textures
thisR.get('texture','macbethchart')
scenes = [scenes, scene];

thisR.set('texture','macbethchart','scale',0.3);
[scene, results] = piWRS(thisR);
scenes = [scenes, scene];

thisR.set('texture','macbethchart','uscale',0.3);
thisR.set('texture','macbethchart','vscale',0.3);
[scene, results] = piWRS(thisR);
scenes = [scenes, scene];

thisR.set('texture','macbethchart','vscale',10);
thisR.set('texture','macbethchart','uscale',10);

thisR.set('asset','001_head_O','material name','head');

[scene, results] = piWRS(thisR);
scenes = [scenes, scene];

% We can loop through and generate a bunch of separate figures
faceImages = {};
for ii=1:numel(scenes)
    faceImages{ii} = cpFacesDetect('scene',scenes{ii},'interactive',false);
end

%%
ieNewGraphWin;
montage(faceImages);

% Now we have an array of images


%%
% The depth map is crazy, though.
% scenePlot(scene,'depth map');

%%

% depthRange = thisR.get('depth range');
% depthRange = [1 1];

%{
    we don't handle oi's yet
% Need to un-comment one lens to have the script run
thisR.set('lens file','fisheye.87deg.100.0mm.json');
% lensFiles = lensList;
lensfile = 'fisheye.87deg.100.0mm.json';
% lensfile  = 'dgauss.22deg.50.0mm.json';    % 30 38 18 10

fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('focal distance',5);
thisR.set('film diagonal',33);

oi = piWRS(thisR);
%}
