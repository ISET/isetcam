function ois = rdtOILoad(varargin)
% Load optical images using Remote Data Toolbox as cell array
%
%   OIs = rdtOILoad(varargin)
%
% Optional Key/value pairs
%   'rdt name'  - RDT project - default is 'isetbio'
%   'remote directory' - Default is '/resources/ois/multiband/scien/shapes'
%   
%   'n oi'  - Number of scenes or list of integers for the scene list
%   'wave' - 400:10:680
%   'fov'  - 10
%
%   'print' - Suppress printing out list of scenes in the remote directory
%             default is true%
% Outputs:
%   ois      - cell array of optical images
%
% Examples:
%     ois = rdtOILoad();
%     ois = rdtOILoad('nOI', 5); % Loads 5 optical images
%
%     
% See also:
%   rdtScenesLoad
% 
% HJ/BW, VISTA TEAM, 2015

%{
 ois = rdtOILoad('n oi',2);
 ieAddObject(ois{1}); oiWindow;
 oiSet(oi,'gamma',0.7);
%}
%{
 ois = rdtOILoad('n oi',[2 4]);
 ieAddObject(ois{1}); oiWindow;
 oiSet(oi,'gamma',0.7);
 ieAddObject(ois{2}); oiWindow;
 oiSet(oi,'gamma',0.7);
%}


%% Parse input parameters
p = inputParser;
varargin = ieParamFormat(varargin);

p.addParameter('noi', inf);
p.addParameter('wave', 400:10:700);
p.addParameter('rdtname', 'isetbio');
p.addParameter('fov', []);
p.addParameter('print',false,@islogical);
p.addParameter('remotedirectory','/resources/ois/multiband/scien/shapes',@ishcar);
p.parse(varargin{:});

nOI     = p.Results.noi;
wave    = p.Results.wave;
rdtName = p.Results.rdtname;
fov     = p.Results.fov;
print   = p.Results.print;
remoteDirectory     = p.Results.remotedirectory;

%% Init remote data toolbox client

% using rdt-config-scien.json configuration file
rdt = RdtClient(rdtName);

% We store some OI data here.  They shouldn't be used for training unless
% they match the camera lens parameters
rdt.crp(remoteDirectory);
fprintf('Loading ois from  %s:%s\n', rdtName, remoteDirectory);

%%
files = rdt.listArtifacts('print',print);

%% Parse the nScenes variable
if isscalar(nOI)
    nOI = min(nOI, length(files));
    sList = 1:nOI;
elseif isvector(nOI)
    if min(nOI) > 0 && max(nOI) <= length(files)
        sList = nOI;
        nOI = length(sList);
    end
end

%% If number of oi is less than 1, we return an empty set
if nOI <= 0, ois = {}; return; end

% load OI files
ois = cell(nOI, 1);
cnt = 1;
for ii = sList
    data = rdt.readArtifact(files(ii).artifactId);
    oi = oiSet(data.oi, 'wave', wave); % adjust wavelength
    if ~isempty(fov), oi = oiSet(oi, 'h fov', fov); end
    ois{cnt} = oi;
    cnt = cnt + 1;
end

end