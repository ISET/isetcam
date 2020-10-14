function ieWebGet(varargin)
%% Download a file from the Stanford web site
%
%
% See also
%


% Examples
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

%% Decode key/val args

varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('remotename');                % Remote file name
p.addParameter('localname','',@ischar);     % Defaults to remote name
p.addParameter('scenetype','pbrt',@ischar); % Helps find the file
p.addParameter('verbose',true,@islogical);  % Tell the user what happened
p.addParameter('list',false,@islogical);    % Assume file download, not dir list
p.parse(varargin);

remoteName  = p.Results.name;
sceneType   = p.Results.scenetype;
verbose     = p.Results.verbose;
localName   = p.Results.localname;
if isempty(localName), localName = remoteName; end


%%
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
        baseURL = 'http://web.stanford.edu/people/wandell/data';
    case {'hyperspectral', 'multispectral', 'hdr'}
        % How do we set the downloadDir in this case?
        baseURL = 'http://web.stanford.edu/people/david81';
    otherwise
        error('sceneType %s not supported.',sceneType);
end

%% We have the download directory, local name, and remote name

%  Check if just a listing. In this case we need the scene type, only
if list
    % Do something
    return;
else
    % Donwload
    downloadFName = fullfile(downloadDir, localName);
    websave(downloadFName,[baseURL,remoteName])
end

%%
if verbose
    disp('Tell the user what happened');
end

% chdir(fullfile(isetbioRootPath,'local'));
% websave('chessSet.zip','http://web.stanford.edu/people/wandell/data/chessSet.zip');

end