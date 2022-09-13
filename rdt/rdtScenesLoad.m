function scenes = rdtScenesLoad(varargin)
% Load multispectral data from the archiva repository
%
% Brief description:
%   scenes = rdtScenesLoad(varargin)
%
% This routine opens a RdtClient and downloads scenes stored in the archiva
% client
%
% Optional key/value pairs
%   'rdt name'  - RDT project - default is 'isetbio'
%   'remote directory' - Default is '/resources/scenes/multiband/scien/faces'
%
%   'n scenes'  - Number of scenes or list of integers for the scene list
%   'wave' - 400:10:680
%   'fov'  - 10
%
%   'print' - Suppress printing out list of scenes in the remote directory
%             default is true
% Outputs:
%   scenes - cell array of multispectral scenes
%   files  - cell array of files (artifacts) in the remote directory
%
% Example:
%     scenes = rdtScenesLoad();
%     scenes = rdtScenesLoad('nScenes', 1); % Loads 1 scenes
%
% HJ/BW, VISTA TEAM, 2015
%
% See also:
%    rdtOILoad();

% TODO
%   We could allow nScenes to be a cell array of artifact names
%

% Examples:
%{
  % Get a two nice Yasuma-Nayar scenes
  scenes = rdtScenesLoad('nscenes',2, ...
              'remote directory','/resources/scenes/multiband/yasuma', ...
              'fov',15);
%}
%{
  scenes = rdtScenesLoad('nscenes',[7 9], ...
              'remote directory','/resources/scenes/multiband/yasuma', ...
              'print',false);
   ieAddObject(scenes{2}); sceneWindow;
%}
%{
   % Get two nice scien, 2009 scenes
  scenes  = rdtScenesLoad('nscenes',2, ...
              'remote directory','/resources/scenes/multiband/scien/2009', ...
              'fov',15, ...
              'wave',410:690);
%}
%{
   % Get two nice scien, 2009 scenes
  scenes = rdtScenesLoad('nscenes',[2 5], ...
              'remote directory','/resources/scenes/multiband/scien/2009', ...
              'fov',15, ...
              'wave',410:690);
   ieAddObject(scenes{1}); sceneWindow;
   ieAddObject(scenes{2}); sceneWindow;
%}
%% Parse input parameters
p = inputParser;
varargin = ieParamFormat(varargin);

p.addParameter('nscenes', inf);
p.addParameter('wave', 400:10:680);
p.addParameter('rdtname', 'isetbio');
p.addParameter('remotedirectory','/resources/scenes/multiband/scien/faces',@ischar);
p.addParameter('fov', 10);
p.addParameter('print',false,@islogical);

p.parse(varargin{:});

nScenes = p.Results.nscenes;
wave    = p.Results.wave;
rdtName = p.Results.rdtname;
fov     = p.Results.fov;
print   = p.Results.print;
remotedirectory = p.Results.remotedirectory;

%% Init remote data toolbox client
rdt = RdtClient(rdtName);  % using rdt-config-scien.json configuration file

% Tell the user what scenes.  We should create more options.
fprintf('Loading scenes from  %s:%s\n', rdtName, remotedirectory);
rdt.crp(remotedirectory);
files = rdt.listArtifacts('print',print);

%% Parse the nScenes variable
if isscalar(nScenes)
    nScenes = min(nScenes, length(files));
    sList = 1:nScenes;
elseif isvector(nScenes)
    if min(nScenes) > 0 && max(nScenes) <= length(files)
        sList = nScenes;
        nScenes = length(sList);
    end
end

%% load scene files
scenes = cell(nScenes, 1);
cnt = 1;
for ii = sList
    data = rdt.readArtifact(files(ii).artifactId);
    % The scene data are stored in various formats.  We decode here
    if isfield(data,'scene')
        scene = data.scene;
    elseif isfield(data,'basis')
        scene = sceneFromBasis(data);
    end
    scene = sceneSet(scene, 'wave', wave); % adjust wavelength
    scenes{cnt} = sceneSet(scene, 'h fov', fov);
    cnt = cnt+1;
end

end