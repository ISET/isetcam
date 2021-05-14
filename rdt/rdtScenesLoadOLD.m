function scenes = rdtScenesLoad(varargin)
% Load multispectral multispectral scenes using Remote Data Toolbox
%
%   scenes = rdtScenesLoad(varargin)
%
% Inputs:
%   varargin - name value pairs for the scene parameters
%
%   'rdtConfigName' - repository name ('isetbio')
%   'fov'        - Field of view      (10)
%   'wave'       - Wavelength samples (400:10:680);
%   'nScenes'    - First n scenes     (1)
%   'sceneNames' - Specific scene names, these are the artifactId
%
% Outputs:
%   scenes - cell array of multispectral scenes
%
% Example:
%   % Load from the default list
%     scenes = rdtScenesLoad('nScenes', 1); % Loads first scene
%     ieAddObject(scenes{1}); sceneWindow;
%
%   % Load from the default list with your wavelength
%     wave = 420:20:500;
%     scenes = rdtScenesLoad('nScenes',2,'wave',wave);
%     ieAddObject(scenes{2}); sceneWindow;
%
% See also:
%   scarletScenesLoad
%
% HJ/BW, VISTA TEAM, 2015

%% Parse input parameters
p = inputParser;
addParameter(p,'sceneNames',...
    {'JapaneseDoll','RedRose', 'AsianFemale_2','MacbethSun'},@iscell)
addParameter(p,'nScenes', inf,@isnumeric);
% addParameter(p,'wave', 400:10:680,@isvector);
addParameter(p,'rdtConfigName', 'isetbio',@ischar);
addParameter(p,'fov', 10);
parse(p,varargin{:});

% Retrieve the results
nScenes    = p.Results.nScenes;
sceneNames = p.Results.sceneNames(1:nScenes);
% wave       = p.Results.wave;
rdtName    = p.Results.rdtConfigName;
fov        = p.Results.fov;

%% Init remote data toolbox client
rdt = RdtClient(rdtName);  % using rdt-config-isetbio.json configuration file
% rdt.crp('/resources/scenes');

% files = rdt.listArtifacts();
% nScenes = min(nScenes, length(files)); % fprintf('Found %d files \n',length(files));
% for ii=1:length(files)
%     fprintf('%d %s\n',ii,files(ii).artifactId);
% end

% Some reason, we need to do this ...
rdt.crp('');
scenes = cell(length(sceneNames), 1);
for ii=1:length(sceneNames)
    artifacts = rdt.searchArtifacts(sceneNames{ii},'type','mat');
    if isempty(artifacts)
        warning('No artifacts named %s\n',sceneNames{ii});
        break;
    else
        nArtifacts = numel(artifacts);
        fprintf('%d artifacts match the term %s\n', nArtifacts,sceneNames{ii});
    end
    
    % Create the scene cell array
    data = rdt.readArtifacts(artifacts(1));
    scene = sceneFromBasis(data{1});
    % scene = sceneSet(scene,'wave',wave);
    scenes{ii} = sceneSet(scene, 'h fov', fov);
end

end