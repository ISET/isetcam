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
%    resource type:
%        {'pbrtv3', 'pbrtv4','spectral','hdr'}
%        (default: 'pbrtv3')
%    resource name    :  Remote file name (no default)
%    remove temp files:  Remove downloaded temporary file (default: true)
%    unzip:           :  Unzip the local file (default: true)
%    verbose          :  Print a report to the command window
%
% Output
%   localFile:  Name of the local download file
%
% Description
%   We store some large data sets (resources) as zip- and mat-files on the
%   Stanford resource, cardinal.stanford.edu.  This routine is a gateway to
%   download those files.  We store them on cardinal because they are too
%   large to be conveniently stored on GitHub.
%
%   The type of resources are listed above.  To see the remote web site or
%   the names of the resources, use the 'browse' option.
%
%   'spectral,'hdr','pbrtv4','pbrtv3'
% 
%    The spectral scenes were measured with multi or hyperspectral cameras.
%    The hdr scenes were measured with multiple exposures of a linear,
%    scientific camera.
%    The PBRT files are either V3 or V4.
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
    % read the list of resources from the remote site. I think we should
    % make this option go away because I don't want to maintain the
    % resource list, and I would like to add more files.
    baseURL = urlResource(varargin{2});
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
p.addParameter('resourcename', '', @ischar);
vFunc = @(x)(ismember(x,{'pbrtv3', 'spectral','hdr','pbrtv4'}));
p.addParameter('resourcetype', 'pbrtv3',vFunc);

p.addParameter('askfirst', true, @islogical);
p.addParameter('unzip', true, @islogical);  % assume the user wants the resource unzipped, if applicable
p.addParameter('localname','',@ischar);     % Defaults to remote name
p.addParameter('removetempfiles', true, @islogical);
p.addParameter('verbose',true,@islogical);  % Tell the user what happened

p.parse(varargin{:});

resourceName   = p.Results.resourcename;
resourceType   = p.Results.resourcetype;
unZip          = p.Results.unzip;
removeTempFiles = p.Results.removetempfiles;

baseURL = urlResource(resourceType);

verbose   = p.Results.verbose;
askFirst  = p.Results.askfirst;
localFile = '';        % Default local file name

%% Download the resource

switch resourceType

    case {'pbrtv3','pbrtv4'}
        % PBRT V3 or V4 resources are zip files.
        %
        % s = ieWebGet('resource type','pbrtv4','resource name','kitchen');

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
            warning('Making download directory error: %s',downloadDir);
            mkdir(downloadDir);
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

    case {'spectral','hdr'}
        % Download mat-files
        % Both are 'spectral' type, but we put the HDR files into a
        % separate directory to make them easier to identify.

        remoteFileName = strcat(resourceName, '.mat');
        resourceURL    = strcat(baseURL, remoteFileName);
        downloadDir = fullfile(isetRootPath,'local','scenes', resourceType);
        if ~isfolder(downloadDir), mkdir(downloadDir); end

        localFile = fullfile(downloadDir, remoteFileName);

        if askFirst
            proceed = confirmDownload(resourceName, localFile);
            if proceed == false, return, end
        end

        try
            websave(localFile, resourceURL);
        catch
            warning("Unable to retrieve %s", resourceURL);
        end
end

end

%% Query the user to confirm the download
function proceed = confirmDownload(resourceName, localFile)

opts.Default = 'No';
opts.Interpreter = 'tex';

% Just show the part of the file from isetcam onward
ii = strfind(localFile,'isetcam');
showFile = localFile(ii:end);

if exist(localFile,'file')
    question = sprintf('\\fontsize{14}%s \nto\n%s\n', resourceName, showFile);
    answer = questdlg(question, 'Overwrite? ', 'Yes', 'No', 'Cancel',opts);
else
    question = sprintf('\\fontsize{14}%s \nto\n%s', resourceName, showFile);
    answer = questdlg(question, 'Download? ', 'Yes', 'No', 'Cancel',opts);
end

if isequal(answer, 'Yes'),  proceed = true;
else,                       proceed = false;
end

end

%% Assign URL to resource type

function [baseURL, urlList] = urlResource(resourceType)
% List the URLs in use here.

urlList = ...
    {'http://stanford.edu/~wandell/data/pbrtv4/', ...
    'http://stanford.edu/~wandell/data/pbrtv3/', ...
    'http://stanford.edu/~wandell/data/hdr/', ...
    'http://stanford.edu/~wandell/data/spectral/', ...
    };

switch resourceType
    case 'all'
        baseURL = urlList;
    case 'pbrtv4'
        baseURL = urlList{1};
    case 'pbrtv3'
        baseURL = urlList{2};
    case 'hdr'
        baseURL = urlList{3};
    case 'spectral'
        baseURL = urlList{4};
    otherwise
        error('Unknown resource type %s\n',src);
end

end

