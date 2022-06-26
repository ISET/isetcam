function localFile = ieWebGet(varargin)
%% Download a resource from the Stanford web site
%
% Synopsis
%   localFile = ieWebGet(varargin)
%
% Brief description
%  Download an ISET or ISET3d related zip or mat-file file from the web.
%  We call these files 'resources'.  The resource type and the remote file
%  name define how to get the file. 
%
% Inputs
%   N/A
%
% Key/val pairs
%
%   'url'     - Print resource urls contained in this file.
%
%   'browse' -  browse a website for a resource
%   'list'   -  return the contents of resourceslist.json on the remote
%               site.  
%    The following argument (varargin{2}) specifies the resource type
%    (see below)
%  
%    ask first: Confirm with user prior to downloading (default: true)
%    op:       One of {'fetch','read'}                 (default: 'fetch')
%    resource type: 
%        {'pbrtv3', 'pbrtv4','spectral','hyperspectral', 'multispectral', 'hdr'}
%        (default: 'pbrt')
%    resource name    :  Remote file name (no default)
%    remove temp files:  Remove downloaded temporary file (default: true)
%    unzip:           :  Unzip the local file (default: true)
%    verbose          :  Print a report to the command window
%
% Output
%   localFile:  Name of the local download file
%
% Description
%   We store certain large data sets (resources) as zip- and mat-files on
%   the Stanford resource, cardinal.stanford.edu.  This routine is a
%   gateway to download the files.  We store them on cardinal because they
%   are too large to be conveniently stored on GitHub.
%
%   The type of resources are listed above.  To see the remote web site or
%   the names of the resources, use the 'browse' option.
%
%   Downloading the different types of resources is handled separately for
%   each resource type. Here is what we do:
%
%   pbrtv3 resources are stored in:   iset3d/data/v3/web
%   pbrtv4 resources are stored in:   iset3d/data/scenes/web
%
%   ('spectral,'hdr','hyperspectral','multispectral') are stored in
%           isetcam/local/scenes/<resourcetype>/. 
%
% See also:
%    webImageBrowser_mlapp
%

% Examples
%{
 % Browse the remote site
 ieWebGet('browse');
 ieWebGet('browse','pbrtv3');
 ieWebGet('browse','hyperspectral');
 ieWebGet('browse','pbrtv4');
%}
%{
 ieWebGet('list')
%}
%{
 localFile = ieWebGet('resource name','veach-ajar');
%}
%{
localFile = ieWebGet('resourcename', 'ChessSet', 'resourcetype', 'pbrt')
data      = ieWebGet('op', 'read', 'resourcetype', 'hyperspectral', 'resourcename', 'FruitMCC')
localFile = ieWebGet('op', 'fetch', 'resourcetype', 'hdr', 'resourcename', 'BBQsite1')
%}
%{
    % Create a cell array of resources and then select one:
    arrayOfResourceFiles = ieWebGet('list', 'hyperspectral')
	data = ieWebGet('op', 'read', 'resource type', 'hyperspectral', 'resource name', arrayOfResourceFiles{ii});
%}

%% First, handle the special input arguments: browse, list, url.

% General argument parsing happens later.

if isequal(ieParamFormat(varargin{1}),'url')
    [~,urlList] = urlResource('all');

    fprintf('\nResource URLs\n=================\n\n');
    for ii=1:numel(urlList)
        fprintf('%s\n',urlList{ii});
    end
    fprintf('\n');
    return;
end

if isequal(ieParamFormat(varargin{1}),'browse')
    % assume for now that means we are looking on the web
    if numel(varargin) < 2
        baseURL = urlResource('default');
    else
        baseURL = urlResource(varargin{2});
    end

    web(baseURL);
    localFile = '';
    return;
end

if isequal(ieParamFormat(varargin{1}),'list')
    % read the list of resources from the remote site.
    % This means someone needs to create the resource list.  Uh Oh.
    try
        localFile = webread(strcat(baseURL, 'resourcelist.json'));
    catch
        % We should find a better way to do this
        warning("Unable to find resourcelist.json on the remote site. Suggest using browse.");
        localFile = webread(baseURL);
    end
    return;
end

%%  Normal situation

varargin = ieParamFormat(varargin);

p = inputParser;
vFunc = @(x)(ismember(x,{'fetch','read','list'}));
p.addParameter('op','fetch',vFunc);
p.addParameter('resourcename', '', @ischar);
vFunc = @(x)(ismember(x,{'pbrtv3', 'spectral','hyperspectral', 'multispectral', 'hdr','pbrtv4'}));
p.addParameter('resourcetype', 'pbrtv3',vFunc);

p.addParameter('askfirst', true, @islogical);
p.addParameter('unzip', true, @islogical);  % assume the user wants the resource unzipped, if applicable
p.addParameter('localname','',@ischar);     % Defaults to remote name
p.addParameter('removetempfiles', true, @islogical);
p.addParameter('verbose',true,@islogical);  % Tell the user what happened

p.parse(varargin{:});

resourceName   = p.Results.resourcename;
resourceType   = p.Results.resourcetype;
% localName      = p.Results.localname;
unZip          = p.Results.unzip;
removeTempFiles = p.Results.removetempfiles;

baseURL = urlResource(resourceType);

% if isempty(localName)
%     localName = resourceName;
% end
verbose   = p.Results.verbose;
op        = p.Results.op;
askFirst  = p.Results.askfirst;
localFile = '';        % Default local file name

switch resourceType
  

    case {'pbrtv3','pbrtv4'}
        % PBRT V3 or V4 resources.
        % We download the file into a directory that is ignored by
        % git.
        %
        % s = ieWebGet('resource type','pbrtv4','resource name','kitchen');

        % This is the only permissible operation for PBRT
        assert(strcmp(op,'fetch')==1)

        % ISET3d must be on your path.
        % The download directory is ignored by git in ISET3d.
        switch resourceType
            case 'pbrtv3'
                downloadDir = fullfile(piRootPath,'data','v3','web');
            case 'pbrtv4'
                downloadDir = fullfile(piRootPath,'data','scenes','web');
        end

        % This should never happen. The directory is part of ISET3d and is
        % a .gitignore directory.
        if ~isfolder(downloadDir)
            error('Download directory error: %s',downloadDir); 
        end

        % We should check if the zip is already there.
        remoteFileName = strcat(resourceName, '.zip');
        resourceURL    = strcat(baseURL, remoteFileName);
        localZIP       = fullfile(downloadDir, remoteFileName);

        if askFirst
            proceed = confirmDownload(resourceName, localZIP);
            if proceed == false, return, end
        end

        try
            % The pbrt files are zip files.
            fprintf('Downloading to %s ... \n',localZIP);
            websave(localZIP, resourceURL);
            fprintf('Done\n');
            if unZip
                unzip(localZIP, downloadDir);
                if removeTempFiles
                    delete(localZIP);
                end
                % not sure how we "know" what the unzip path is?
                localFile = fullfile(downloadDir, resourceName);
            else
                localFile = localZIP;
            end
        catch
            warning("Failed to retrieve: %s", resourceURL);
            localFile = '';
        end
        
    case {'spectral','hyperspectral', 'multispectral', 'hdr'}
        
        % We need to adjust the baseurl for these non-pbrt cases
        parentURL = 'http://stanford.edu/~david81/ISETData/';
        % do we want to switch based on browse op or
        % split by type first?
        switch resourceType
            case 'hyperspectral'
                baseURL = strcat(parentURL, "Hyperspectral", '/');
            case 'multispectral'
                baseURL = strcat(parentURL, "Multispectral", '/');
            case 'hdr'
                baseURL = strcat(parentURL, "HDR", '/');
        end
        
        switch op
            case {'read', 'fetch'}
                options = weboptions('Timeout', 60);
                if ~endsWith(resourceName, "." + lettersPattern)
                    remoteFileName = strcat(resourceName, '.mat');
                else
                    remoteFileName = resourceName;
                end
                resourceURL = strcat(baseURL, remoteFileName);
                switch op
                    case {'fetch','read'}
                        if exist('isetRootPath','file') && isfolder(isetRootPath)
                            downloadRoot = isetRootPath;
                            downloadDir = fullfile(downloadRoot, 'local', 'scenes', resourceType);
                            if ~isfolder(downloadDir)
                                mkdir(downloadDir)
                            end
                        else
                            error("Need to have root path set for isetcam or isetbio.");
                        end
                        
                        localFile = fullfile(downloadDir, remoteFileName);
                        if askFirst
                            proceed = confirmDownload(resourceName, localFile);
                            if proceed == false, return, end
                        end
                        
                        try
                            websave(localFile, resourceURL, options);
                        catch
                            warning("Unable to retrieve %s", resourceURL);
                        end
                        if isequal(op, 'read')
                            % in this case we are actually returning a Matlab
                            % array with scene data!
                            stashFile = localFile;
                            localFile = load(stashFile);
                            if removeTempFiles
                                delete(stashFile);
                            end
                        end
                        
                end
           
            otherwise
                warning("Not Supported yet");
        end
        
    otherwise
        error('sceneType %s not supported.',resourceType);
end

%% Tell the user what happened
if verbose
    if ischar(localFile)
        disp(strcat("Retrieved: ", resourceName, " to: ", localFile));
    elseif isstruct(localFile)
        disp(strcat("Retrieved: ", resourceName, " and returned as a struct"));
    elseif exist('localFile','file') && ~isempty(localFile)
        disp(strcat("Retrieved: ", resourceName, " and returned it as an array"));
    elseif ~isequal(op,'list')
        disp(strcat("Unable to Retrieve: ", resourceName));
    end
end

end

%% Query the user to confirm the download
%
function proceed = confirmDownload(resourceName, localZIP)

question = sprintf('Confirm download: %s to %s\n', resourceName, localZIP);
answer = questdlg(question, 'Confirm Download: ', 'Yes');

% To change the font size ...
% questdlg('\fontsize{20}Hello World ?','Hello',struct('Default','','Interpreter','tex'));

if isequal(answer, 'Yes'),  proceed = true;
else,                       proceed = false;
end

end

%% Assign URL to resource type

function [baseURL, urlList] = urlResource(resourceType)
% List the possible URLs here

urlList = ...
    {'http://stanford.edu/~wandell/data/pbrtv3/', ...
    'http://stanford.edu/~david81/ISETData/Hyperspectral/', ...
    'http://stanford.edu/~david81/ISETData/Multispectral/', ...
    'http://stanford.edu/~david81/ISETData/HDR/', ...
    'http://stanford.edu/~wandell/data/spectral/', ...
    'http://stanford.edu/~wandell/data/pbrtv4/'};

switch resourceType
    case 'all'
    case 'pbrtv3'
        baseURL = urlList{1};
    case 'hyperspectral'
        baseURL = urlList{2};
    case 'multispectral'
        baseURL = urlList{3};
    case 'hdr'
        baseURL = urlList{4};
    case 'spectral'
        baseURL = urlList{5};
    case 'pbrtv4'
        baseURL = urlList{6};
    otherwise
        error('Unknown resource type %s\n',src);
end

end

