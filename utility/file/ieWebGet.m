function localFile = ieWebGet(varargin)
%% Download a resource from a Stanford web site
%
% Synopsis
%   localFile = ieWebGet(varargin)
%
% Brief description
%   Download an ISET related files from the web.  Used for ISETCam and
%   ISET3d data.
%
% Inputs
%   N/A
%
% Key/val pairs
%
%   'browse' -  browse a website contaning useful files
%   'list'   -  list the remote websites
%
%    The following argument (varargin{2}) specifies the resource type
%    (see below)
%
%    confirm:       Confirm with user prior to downloading (default: true)
%    resource type (default: 'pbrtv4')
%    resource file    :  Remote file name (no default)
%    remove temp files:  Remove downloaded temporary file (default: true)
%    unzip:           :  Unzip the local file (default: true)
%    verbose          :  Print a report to the command window
%    downloaddir      :  Directory for download
%
% Output
%   localFile:  Name of the local download file
%
% Description
%   We store large data sets (resources) as zip- and mat-files on the
%   Stanford resource, Stanford Digital Repository (SDR).  This
%   routine is a gateway to download files from there. We store them
%   on SDR because they are too large to be conveniently stored on
%   GitHub.
%
%   The various resources we currently download can be returned using
%
%     ieWebGet('list')
% 
% To see the remote web site or
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
ieWebGet('list')
%}
%{
% Browse the remote site
ieWebGet('browse','pbrtv4');
%}
%{
localFile = ieWebGet('resourcetype', 'pbrtv4','resourcefile','kitchen.zip');
%}
%{
localFile = ieWebGet('resourcetype', 'iset3d','resourcefile','SimpleScene');
%}
%{
localFile = ieWebGet('resourcetype', 'bitterli','resourcefile','cornell-box');
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

%% Manage the list and browse conditions

%------- list --------
if isequal(ieParamFormat(varargin{1}),'list')
    % ieWebGet('list');
    resourceList = urlResource('all');

    fprintf('\nResource types\n=================\n\n');
    for ii=2:numel(resourceList)
        fprintf('%s\n',resourceList{ii});
    end
    fprintf('\n');
    localFile = resourceList(:,1);
    return;
end

%------- browse --------
if isequal(ieParamFormat(varargin{1}),'browse')
    if numel(varargin) < 2, resourceType = 'pbrtv4';
    else,                   resourceType = varargin{2};
    end

    resource = urlResource(resourceType);
    
    web(resource{3});
    localFile = '';
    return;
end

%%  Download

% Forces the file names to lower case, which is how they are stored on
% the SDR, too, for pbrtv4, bitterli, and iset3d-scenes.  But NOT for
% some of the other resources.  So, wondering what to do (BW).
varargin = ieParamFormat(varargin);
[~,validResources] = urlResource('all');

p = inputParser;
vFunc = @(x)(ismember(ieParamFormat(x),validResources));
p.addParameter('resourcetype', 'pbrtv4',vFunc);
p.addParameter('resourcefile', '', @ischar);

p.addParameter('confirm', true, @islogical);
p.addParameter('unzip', true, @islogical);  % assume the user wants the resource unzipped, if applicable
p.addParameter('localname','',@ischar);     % Defaults to remote name
p.addParameter('removetempfiles', true, @islogical);
p.addParameter('verbose',true,@islogical);  % Tell the user what happened
p.addParameter('downloaddir','',@ischar);

p.parse(varargin{:});

resourceType   = p.Results.resourcetype;
resourceFile   = p.Results.resourcefile;
unZip          = p.Results.unzip;
removeTempFiles = p.Results.removetempfiles;

% verbose   = p.Results.verbose;
confirm  = p.Results.confirm;
localFile = '';        % Default local file name

%% Download the resource

resource = urlResource(resourceType);
resourceURL = resource(4);

switch ieParamFormat(resourceType)

    case {'pbrtv4','bitterli','iset3d-scenes'}
        % 
        
        % s = ieWebGet('resource type','pbrtv4','resource file','kitchen.zip');

        % ISET3d must be on your path.
        if ~isempty(p.Results.downloaddir)
            % The user gave us a place to download to.
            downloadDir = p.Results.downloaddir;
        else
            downloadDir = fullfile(piRootPath,'data','scenes','web');
        end

        % This should never happen. The directory is part of ISET3d and is
        % a .gitignore directory.
        if ~isfolder(downloadDir)
            warning('Making download directory error: %s',downloadDir);
            mkdir(downloadDir);
        end

        % We should check if the zip is already there.
        [~,~,e] = fileparts(resourceFile);
        if ~isequal(e,'.zip')
            remoteFileName = strcat(resourceFile, '.zip');
        else, remoteFileName = resourceFile;
        end
        remoteURL    = strcat(resourceURL{1}, '/',remoteFileName);
        localZIP     = fullfile(downloadDir, remoteFileName);

        if confirm
            proceed = confirmDownload(resourceFile, localZIP);
            if proceed == false, return, end
        end

        try
            % The pbrt files are zip files.
            fprintf('Downloading to %s ... \n',localZIP);
            websave(localZIP, remoteURL);
            fprintf('Done\n');
            if unZip
                unzip(localZIP, downloadDir);
                if removeTempFiles
                    delete(localZIP);
                end
                % not sure how we "know" what the unzip path is?
                localFile = fullfile(downloadDir, resourceFile);
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
        if isempty(resourceFile)
            error('Resource file name is required for type %s.',resourceType);
        end

        remoteFileName = strcat(resourceFile, '.mat');
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
            proceed = confirmDownload(resourceFile, localFile);
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
            proceed = confirmDownload(resourceFile, localFile);
            if proceed == false, return, end
        end

        try
            fprintf('Downloading ...')
            websave(localFile, baseURL);
            fprintf('done.\n');
        catch
            warning("Unable to retrieve %s", baseURL);
        end
    case {'isethdrsensor'}
        if ~isempty(p.Results.downloaddir)
            % The user gave us a place to download to.
            downloadDir = p.Results.downloaddir;
        else
            % Go to local/sdr
            downloadDir = fullfile(isetRootPath,'local','sdr');
        end
        
        localFile = fullfile(downloadDir, resourceFile);
        localDir  = fileparts(localFile);
        if ~isfolder(localDir), mkdir(localDir); end
        remoteURL = fullfile(baseURL,resourceFile);
        try
            fprintf('*** Downloading %s from ISETHDRSensor SDR ... \n',resourceFile);
            websave(localFile, remoteURL);
            fprintf('*** File is downloaded! \n');
        catch
            warning("Unable to retrieve %s", remoteURL);
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

function [resource, validResources] = urlResource(resourceType)
% List the URLs in use here.
%
% This needs to be a better search mechanism so we can put in more general
% names for the resource type.
%
% See also
%

% Example:
%{
resourceType = 'faces-1M';
%}

if notDefined('resourceType'), resourceType = 'all'; end

% An N x 4 cell array
%
% resource name, SDR name, SDR purl, SDR data url
resourceCell = {...
    'bitterli','ISET 3d Scenes bitterli', 'https://purl.stanford.edu/cb706yg0989', 'https://stacks.stanford.edu/file/druid:cb706yg0989/sdrscenes/bitterli';
    'pbrtv4',  'ISET 3d Scenes pharr', 'https://purl.stanford.edu/cb706yg0989',    'https://stacks.stanford.edu/file/druid:cb706yg0989/sdrscenes/pbrtv4';
    'iset3d-scenes', 'ISET 3d Scenes iset3d', 'https://purl.stanford.edu/cb706yg0989', 'https://stacks.stanford.edu/file/druid:cb706yg0989/sdrscenes/iset3d-scenes';
    'isethdrsensor','ISET HDR Sensor', 'https://purl.stanford.edu/bt316kj3589', 'https://stacks.stanford.edu/file/druid:bt316kj3589/isethdrsensor';
    'people-multispectral','ISET multispectral scenes of people','https://purl.stanford.edu/mv668yq1424', '';
    'landscape-hyperspectral','ISET hyperspectral scene data for landscapes','https://purl.stanford.edu/dy318qn9992', 'https://stacks.stanford.edu/file/druid:dy318qn9992';
    'faces-3m','ISET scenes of faces at 3M', 'https://purl.stanford.edu/rr512xk8301','';
    'faces-1m','ISET hyperspectral scenes of human faces at high resolution, 1M distance', 'https://purl.stanford.edu/jj361kc0271',''
    'fruits-charts','ISET scenes with fruits and calibration charts','https://purl.stanford.edu/tb259jf5957', '';
    'misc-multispectral1','ISET multispectral scenes of faces, fruit, objects, charts','https://purl.stanford.edu/sx264cp0814', '';
    'misc-multispectral2','ISET multispectral scenes of fruit, books, color calibration charts','https://purl.stanford.edu/vp031yb6470','';
    };

validResources = resourceCell(:,1);

if isequal(resourceType,'all')
    % Return the cell arrays
    resource = resourceCell;
    return;
else
    % Find the matching one.
    idx = contains(validResources,ieParamFormat(resourceType));
    resource = resourceCell(idx,:);
end

end

