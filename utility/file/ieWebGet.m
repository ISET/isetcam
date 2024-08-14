function localFile = ieWebGet(varargin)
%% Download a resource from a Stanford web site
%
% Synopsis
%   localFile = ieWebGet(varargin)
%
% Brief description
%  Download an ISET or ISET3d related zip or mat-file file from the web.
%  We call these files 'resources'.  The resource type and the remote file
%  name are used to define how to get the file.
%
%  When the files are PBRT V4 files, we download by default to the
%  local directory in ISET3d-tiny (or ISET3d).  For other files to the
%  local directory in ISETCam. 
%
% Inputs
%   N/A
%
% Key/val pairs
%
%   'browse' -  browse a website for a resource
%   'list'   -  return the contents of resourceslist.json on the remote
%               site.
%    The following argument (varargin{2}) specifies the resource type
%    (see below)
%
%    confirm:       Confirm with user prior to downloading (default: true)
%    resource type (default: 'pbrtv4')
%        {'pbrtv4', 'pbrtv3','spectral','hdr','faces'}
%    
%    resource name    :  Remote file name (no default)
%    remove temp files:  Remove downloaded temporary file (default: true)
%    unzip:           :  Unzip the local file (default: true)
%    verbose          :  Print a report to the command window
%    downloaddir      :  Directory for download
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
%   'spectral,'hdr','pbrtv4'
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
ieWebGet('list');
%}
%{
% Browse the remote site
ieWebGet('browse','pbrtv4');
ieWebGet('browse','spectral');
ieWebGet('browse','faces');
%}
%{
% PBRT V4 is default
localFile = ieWebGet('resource name','lettersAtDepth');
%}
%{
localFile = ieWebGet('resourcename', 'ChessSet', 'resourcetype', 'pbrtv4')
localFile = ieWebGet('resourcetype', 'spectral', 'resourcename', 'FruitMCC')
localFile = ieWebGet('resourcetype', 'hdr', 'resourcename', 'BBQsite1')
%}
%{
% Starting to implement SDR data
fname = ieWebGet('resource type','sdrfruit','askfirst',false,'unzip',true);
%}
%{
fname = ieWebGet('resource type','sdr multispectral');
%}

%% General argument parsing happens later.

[~,validResources] = urlResource;

if isequal(ieParamFormat(varargin{1}),'list')
    % ieWebGet('list');
    urlList = urlResource('all');

    fprintf('\nResource URLs\n=================\n\n');
    for ii=2:numel(urlList)
        fprintf('%s\n',urlList{ii});
    end
    fprintf('\n');
    return;
end

if isequal(ieParamFormat(varargin{1}),'browse')
    % Assume we are looking on the web at Wandell's cardinal account.
    % This works for the url locations 2-5, but not the others
    if numel(varargin) < 2
        baseURL = urlResource('default');
    else
        baseURL = urlResource(varargin{2});
    end
    
    web(baseURL);
    localFile = '';
    return;
end


%%  Normal situation

varargin = ieParamFormat(varargin);

p = inputParser;
p.addParameter('resourcename', '', @ischar);
vFunc = @(x)(ismember(ieParamFormat(x),validResources));
p.addParameter('resourcetype', 'pbrtv4',vFunc);

p.addParameter('confirm', true, @islogical);
p.addParameter('unzip', true, @islogical);  % assume the user wants the resource unzipped, if applicable
p.addParameter('localname','',@ischar);     % Defaults to remote name
p.addParameter('removetempfiles', true, @islogical);
p.addParameter('verbose',true,@islogical);  % Tell the user what happened
p.addParameter('downloaddir','',@ischar);

p.parse(varargin{:});

resourceName   = p.Results.resourcename;
resourceType   = p.Results.resourcetype;
unZip          = p.Results.unzip;
removeTempFiles = p.Results.removetempfiles;

baseURL = urlResource(resourceType);

% verbose   = p.Results.verbose;
confirm  = p.Results.confirm;
localFile = '';        % Default local file name

%% Download the resource

switch ieParamFormat(resourceType)

    case {'pbrtv4'}
        % PBRT V4 resources are zip files.
        %
        % s = ieWebGet('resource type','pbrtv4','resource name','kitchen');

        % ISET3d must be on your path.
        if ~isempty(p.Results.downloaddir)
            % The user gave us a place to download to.
            downloadDir = p.Results.downloaddir;
        else
            switch resourceType
                case 'pbrtv3'
                    downloadDir = fullfile(piRootPath,'data','v3','web');
                case 'pbrtv4'
                    downloadDir = fullfile(piRootPath,'data','scenes','web');
            end
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

    case {'spectral','hdr','faces'}
        % Download mat-files
        % Both are 'spectral' type, but we put the HDR files into a
        % separate directory to make them easier to identify.
        if isempty(resourceName)
            error('Resource file name is required for type %s.',resourceType);
        end

        remoteFileName = strcat(resourceName, '.mat');
        resourceURL    = strcat(baseURL, remoteFileName);
        if ~isempty(p.Results.downloaddir)
            % The user gave us a place to download to.
            downloadDir = p.Results.downloaddir;
        else
            downloadDir = fullfile(isetRootPath,'local','scenes', resourceType);
        end

        if ~isfolder(downloadDir), mkdir(downloadDir); end
        localFile = fullfile(downloadDir, remoteFileName);

        if confirm
            proceed = confirmDownload(resourceName, localFile);
            if proceed == false, return, end
        end

        try
            websave(localFile, resourceURL);
        catch
            warning("Unable to retrieve %s", resourceURL);
        end
    case {'sdrfruit','sdrmultispectral'}
        % All the SDR initialized resources from the Stanford Digital
        % Repository.  Not quite sure how we will manage in the end.
        switch ieParamFormat(resourceType)
            case 'sdrfruit'
                remoteFileName = 'ISET_Fruit.zip';
            case 'sdrmultispectral'
                remoteFileName = 'MultispectralDataset2.zip';
            otherwise
                % Can never get here.
        end

        if ~isempty(p.Results.downloaddir)
            % The user gave us a place to download to.
            downloadDir = p.Results.downloaddir;
        else
            % Go to local/sdr
            downloadDir = fullfile(isetRootPath,'local','sdr');
        end

        if ~isfolder(downloadDir), mkdir(downloadDir); end
        localFile = fullfile(downloadDir, remoteFileName);

        if askFirst
            proceed = confirmDownload(resourceName, localFile);
            if proceed == false, return, end
        end

        try
            fprintf('Downloading ...')
            websave(localFile, baseURL);
            fprintf('done.\n');
        catch
            warning("Unable to retrieve %s", baseURL);
        end
end

end

%% Query the user to confirm the download
function proceed = confirmDownload(resourceName, localFile)

opts.Default = 'No';
opts.Interpreter = 'tex';

% Just show the part of the file from isetcam or iset3d onward
ii = strfind(localFile,'isetcam');
if isempty(ii)
    ii = strfind(localFile,'iset3d');
end
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

function [baseURL, validResources] = urlResource(resourceType)
% List the URLs in use here.
%
% This needs to be a better search mechanism so we can put in more general
% names for the resource type.
%
% See also
%


if ieNotDefined('resourceType'), resourceType = 'all'; end

validResources = {'pbrtv4','spectral','hdr','faces','sdrfruit','sdrmultispectral'};

% We should maintain something like this:
%{
ii = 1;
sdrWeb(ii).names = {'isetmultispectral'};
sdrWeb(ii).purl = 'https://purl.stanford.edu/vp031yb6470';
sdrWeb(ii).files = {'montage.jpg','MultispectralDataset2.zip'};
sdrWeb(ii).fileurl = 'https://stacks.stanford.edu/file/druid:vp031yb6470'; 
websave('tmp.jpg',fullfile(sdrWeb(1).fileurl,sdrWeb(1).files{1}))
web(sdrWeb(1).purl);

%}


urlList = ...
    {'http://stanford.edu/~wandell/data', ...
    'http://stanford.edu/~wandell/data/pbrtv4/', ...
    'http://stanford.edu/~wandell/data/hdr/', ...
    'http://stanford.edu/~wandell/data/spectral/', ...
    'http://stanford.edu/~wandell/data/faces/', ...
    'https://stacks.stanford.edu/v2/file/tb259jf5957/version/1/ISET_fruit.zip',...
    'https://stacks.stanford.edu/file/druid:vp031yb6470/MultispectralDataset2.zip'
    };

switch ieParamFormat(resourceType)
    case {'all',''}
        baseURL = urlList;
    case 'pbrtv4'
        baseURL = urlList{2};
    case 'hdr'
        baseURL = urlList{3};
    case 'spectral'
        baseURL = urlList{4};
    case 'faces'
        baseURL = urlList{5};
    case 'sdrfruit'
        baseURL = urlList{6};
    case 'sdrmultispectral'
        baseURL = urlList{7};
    otherwise
        error('Unknown resource type %s\n',src);
end

end

