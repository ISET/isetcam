function localFile = ieWebGet(varargin)
%% Download a resource from the Stanford web site
%
%
% See also
%
% Examples
%{
resourcetype - hyperspectral, multispectral, hdr, pbrt, V3....
resourcename - name of the scene or image
op - 'fetch', 'browse', (someday 'list'/'dir')
askfirst - confirm download
verbose - tell the user what we did
readonly - (possible for images)
{dir,ls} - use webread rather than websave to list the directory
%}
%{
   localFile       = ieWebGet('resourcename', 'ChessSet', 'resourcetype', 'pbrt')
   ~                = ieWebGet('resourcetype', 'pbrt', 'op', 'browse')
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
p.addParameter('unzip', true); % assume the user wants the resource unzipped, if applicable
p.addParameter('localname','',@ischar);     % Defaults to remote name
p.addParameter('removetempfiles', true);
p.addParameter('verbose',true,@islogical);  % Tell the user what happened
p.addParameter('op','fetch',@ischar);  %or can list or browse

p.parse(varargin{:});

resourceName   = p.Results.resourcename;
resourceType   = p.Results.resourcetype;
localName = p.Results.localname;
unZip = p.Results.unzip;
removeTempFiles = p.Results.removetempfiles;

if isempty(localName), localName = resourceName; end
verbose = p.Results.verbose;
op = p.Results.op;
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
        
        baseURL = 'http://stanford.edu/~wandell/data/pbrt/';
        switch op
            case 'fetch'
                % for now we only support v3 pbrt files
                downloadDir = fullfile(downloadRoot,'data','v3');
                if ~isfolder(downloadDir)
                    mkdir(downloadDir);
                end
                
                remoteFileName = strcat(resourceName, '.zip');
                resourceURL = strcat(baseURL, remoteFileName);
                localURL = fullfile(downloadDir, remoteFileName);
                
                proceed = confirmDownload(resourceName, resourceURL, localURL);
                if proceed == false, return, end
                
                try
                    websave(localURL, resourceURL);
                    if unZip
                        unzip(localURL, downloadDir);
                        if removeTempFiles
                            delete(localURL);
                        end
                        % not sure how we "know" what the unzip path is?
                        localFile = fullfile(downloadDir, resourceName);
                    else
                        localFile = localURL;
                    end
                catch
                    %not much in the way of error handling yet:)
                    warning("Unable to retrieve: %s", resourceURL);
                    localFile = '';
                end
            case 'browse'
                % assume for now that means we are listing
                web(baseURL);
                localFile = '';
                
        end
    case {'hyperspectral', 'multispectral', 'hdr'}
        baseURL = 'http://stanford.edu/~david81/ISETData';
    otherwise
        error('sceneType %s not supported.',resourceType);
end

        

%%
if verbose
    disp(strcat("Retrieved: ", resourceName, " to: ", localFile));
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
