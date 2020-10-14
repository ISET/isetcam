function localFile = ieWebGet(varargin)
%% Download a resource from the Stanford web site
%
%
% See also
%
% Examples
%{
resourcetype - hyperspectral, multispectral, hdr, pbrt, ....
readonly - (possible for images)
{dir,ls} - use webread rather than websave to list the directory
%}
%{
   localFile       = ieWebGet('resourcename', 'ChessSet', 'resourcetype', 'pbrt')
   saveFile       = ieWebGet('resourceName','barbecue.jpg','resourcetype','hdr');
   dataFromFile   = ieWebGet('thisMatFile','type','hyperspectral','readonly',true);
   listOfTheFiles = ieWebGet('resourcetype','V3','dir',true)
   % Bring up the browser   
   url            = ieWebGet('resourcetype','hyperspectral','browse',true); 
%}
%{
  listOfTheFiles = ieWebGet('','type','V3','dir',true)
  % determine which ii value
  dataFromFile   = ieWebGet(listOfTheFiles{ii},'type','V3','readonly',true);
%}

%% Decode key/val args

varargin = ieParamFormat(varargin);

p = inputParser;
p.addParameter('resourcename', '');
p.addParameter('resourcetype', 'pbrt');
p.addParameter('askfirst', true);
p.addParameter('localname','',@ischar);     % Defaults to remote name
p.addParameter('removetempfiles', true);
p.addParameter('verbose',true,@islogical);  % Tell the user what happened
p.addParameter('list',false,@islogical);    % This or maybe if resourceName is ''?

p.parse(varargin{:});

resourceName   = p.Results.resourcename;
resourceType   = p.Results.resourcetype;
localName = p.Results.localname;

if isempty(localName), localName = resourceName; end
verbose = p.Results.verbose;
list = p.Results.list;
askFirst = p.Results.askfirst;

switch resourceType
    case {'pbrt', 'V3'}
        if exist('piRootPath') && isfolder(piRootPath) 
            downloadRoot = piRootPath;
        elseif exist(isetRootPath, 'var') && isfolder(isetRootPath)
            downloadRoot = isetRootPath;
        else
            error("Need to have either iset3D or isetCam Root set");
        end
        % for now we only support v3 pbrt files
        downloadDir = fullfile(downloadRoot,'data','v3');
        if ~isfolder(downloadDir)
            mkdir(downloadDir);
        end
        baseURL = 'http://stanford.edu/~wandell/data/pbrt/';
        
        remoteFileName = strcat(resourceName, '.zip');
        resourceURL = strcat(baseURL, remoteFileName);
        localURL = fullfile(downloadDir, remoteFileName);
        
        proceed = confirmDownload(resourceName, resourceURL, localURL);
        if proceed == false, return, end

        try
            websave(localURL, resourceURL);
            unzip(localURL, downloadDir);
            if removetempfiles
                delete(localURL);
            end
            localFile = localURL;
        catch
            %not much in the way of error handling yet:)
            warning("Unable to retrieve: %s", resourceURL);
            localFile = '';
        end
        
    case {'hyperspectral', 'multispectral', 'hdr'}
        baseURL = 'http://stanford.edu/~david81';
    otherwise
        error('sceneType %s not supported.',resourceType);
end

        

%%
if verbose
    disp('Tell the user what happened');
end

end

function proceed = confirmDownload(resourceName, resourceURL, localURL)
    question = sprintf("Okay to download: %s from %s to file %s and unzip it?\n This may take some time.", resourceName, resourceURL, localURL);
    answer = questdlg(question, "Confirm Web Resource Download", 'Yes');
    if isequal(answer, 'Yes')
        proceed = true;
    else
        proceed = false;
    end 
end
