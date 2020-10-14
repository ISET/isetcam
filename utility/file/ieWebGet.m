%% Download a file from the Stanford web site
%

function ieWebGet(varargin)

%{
filetype - hyperspectral, multispectral, hdr, pbrt, ....
readonly - (possible for images)
{dir,ls} - use webread rather than websave to list the directory
%}
%{
   saveFile       = ieWebGet('remote file','chessSet.zip','type','V3');
   saveFile       = ieWebGet('remote file','barbecue.jpg','type','hdr');
   dataFromFile   = ieWebGet('thisMatFile','type','hyperspectral','readonly',true);
   listOfTheFiles = ieWebGet('type','V3','dir',true)
   % Bring up the browser   
   url            = ieWebGet('type','hyperspectral','browse',true); 
%}
%{
  listOfTheFiles = ieWebGet('','type','V3','dir',true)
  % determine which ii value
  dataFromFile   = ieWebGet(listOfTheFiles{ii},'type','V3','readonly',true);
%}

p = inputParser;
p.addRequired('name');
p.addParameter('scenetype');
p.parse(varargin);

sceneName   = p.Results.name;
sceneType   = p.Results.scenetype;

switch sceneType
    case 'pbrt'
        if exist(piRootPath, 'var') && isfolder(piRootPath) 
            downloadRoot = piRootPath;
        elseif exist(isetRootPath, 'var') && isfolder(isetRootPath)
            downloadRoot = isetRootPath;
        else
            error("Need to have either iset3D or isetCam Root set");
        end
        % for now we only support v3 pbrt files
        downloadDir = fullfile(downloadRoot,'data','v3');
        baseURL = 'http://web.stanford.edu/people/wandell/data'
    case {'hyperspectral', 'multispectral', 'hdr'}
        baseURL = 'http://web.stanford.edu/people/david81'
    otherwise
        error('not supported yet');
end

downloadFName = fullfile(downloadDir, sceneName);

websave(downloadFName,[baseURL,remoteFileName])

% chdir(fullfile(isetbioRootPath,'local'));
websave('chessSet.zip','http://web.stanford.edu/people/wandell/data/chessSet.zip');

end