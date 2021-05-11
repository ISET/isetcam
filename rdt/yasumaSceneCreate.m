%% Convert Yasuma-Nayar data to ISETCAM scenes
%
% Downloaded the raw data from here
%
%  http://www.cs.columbia.edu/CAVE/databases/multispectral/
%
% Put the unzipped files in isetcam/local/Yasuma-Nayar
%
% Built up the scenes as below, and then pushed them up to the
% RemoteDataClient inside of isetbio repository as
%
%  /resources/scenes/multiband/yasuma
%

%%
baseDir = fullfile(isetRootPath, 'local', 'Yasuma-Nayar');
chdir(baseDir);
files = dir('*_ms');

%% Loop through all the scenes and save them out as _scene.mat
for ff = 1:length(files)
    file = files(ff).name;
    fprintf('Converting %s\n', file);
    chdir(fullfile(isetRootPath, 'local', 'Yasuma-Nayar', file, file));

    scene = sceneCreate;
    illD65 = sceneGet(scene, 'illuminant photons');
    reflectance = zeros(512, 512, 31);

    for ii = 1:31
        thisFile = sprintf('%s_%.2d.png', file, ii);
        data = imread(thisFile);
        reflectance(:, :, ii) = data(:, :, 1);
    end
    photons = RGB2XWFormat(reflectance) * diag(illD65);
    photons = XW2RGBFormat(photons, 512, 512);

    scene = sceneSet(scene, 'photons', photons);
    scene = sceneAdjustLuminance(scene, 100);
    % ieAddObject(scene); sceneWindow;

    chdir(fullfile(baseDir, 'yasumaScenes'));
    thisScene = [file, '_scene'];
    save(thisScene, 'scene');
end

%%  Open up and look at the different scenes

chdir(fullfile(baseDir, 'yasumaScenes'));
scenes = dir('*_scene.mat');
for ii = 1:length(scenes)
    thisScene = scenes(ii).name;
    fprintf('Load %s \n', thisScene);
    load(thisScene, 'scene');
    if ii == 1
        ieAddObject(scene);
        sceneWindow;
        truesize;
    else
        ieReplaceObject(scene);
    end
    sceneWindow;
    pause(1);
end

%% Upload to Remote Data Client

rd = RdtClient('isetbio');
rd.credentialsDialog;
chdir(baseDir);
rd.crp('/resources/scenes/multiband');
rd.listArtifacts('print', true);

rd.publishArtifacts(fullfile(baseDir, 'yasumaScenes'), ...
    'remotePath', '/resources/scenes/multiband/yasuma');
rd.crp('/resources/scenes/multiband/yasuma');
rd.listArtifacts('print', true);

%%
