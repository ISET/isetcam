function [localFile, zipfilenames] = ieWebGet(varargin)
%% Download a zip file from a Stanford Digital Repository deposit
%
% Synopsis
%   [localFile,zipfilenames] = ieWebGet(varargin)
%
% Brief description
%   Download a zip file from a deposit in the Stanford Digital Reposition.
%   Used for ISETCam, ISET3d, ISETBio, and related data files.
%
% Inputs
%   N/A
%
% Key/val pairs
%
%   'list'   -  list the websites we know about
%   'browse' -  browse the website with the deposited files
%
%    The following argument (varargin{2}) specifies the resource type
%    (see below)
%
%    deposit type     :  SDR deposit name (default: 'pbrtv4')
%    deposit file     :  Deposit file name (default: depends on deposit)
%    downloaddir      :  Download directory (default: depends on deposit)
%
%    confirm:         :  Confirm prior to download (default: true)
%    unzip:           :  Unzip after download (default: true)
%    remove zip file  :  Remove the zip file (default: true)
%
% Output
%   localFile:  Full path to the downloaded zip file.  If unzipped, then a
%               full path to the directory where the files have been
%               unzipped.
%   fnames:     When the file is unzipped, we also return the filenames
%               from the unzip directory
%
% Description
%  ISET files that are too large for a GitHub repository in the Stanford
%  Digital Repository (SDR). SDR calls a group of files a 'deposit'.
%  Multiple deposits from a research group are called a collection.
%
%  This routine downloads files from an SDR deposit to your local computer.
%
%  We know about these SDR deposits
%
%     ieWebGet('list')
%
%  To use a browser to view a deposit or a collection, use the
% 'browse' option. Such as, these deposits
%
%     ieWebGet('browse','pbrtv4');
%     ieWebGet('browse','hdr-images');
%
%  Or these collections
%
%     ieWebGet('browse','vistalab-collection');
%     ieWebGet('browse','iset-hyperspectral-collection');
%     ieWebGet('browse','iset-multispectral-collection');
%
% Notes and TODO
%  * We should be able to take a cell array of deposit files, not just one.
%  * Some deposits only have two files.  We should probably unpack the zip
%  file that contains multiple other files so they can be accessed
%  individually.
%
% Information about the deposited files are on the SDR web pages. Here are
% a few notes.
%
%  * The spectral scenes were measured with multi or hyperspectral cameras.
%  * The hdr scenes were measured with multiple exposures of a linear, scientific camera.
%  * The PBRT files are for ISET3d-tiny and PBRT V4.
%  * The *papers* deposits are connected to publications, and the files are
%    highly idiosyncratic.
%
% See also:
%    webImageBrowser_mlapp
%

%{
% Browse the remote site
ieWebGet('browse','pbrtv4');
ieWebGet('browse','iset3d-scenes');
ieWebGet('browse','bitterli');
ieWebGet('browse','vistalab-collection');

ieWebGet('browse','iset-multispectral-collection');
ieWebGet('browse','people-multispectral');  % ISET Multispectral Image Database
ieWebGet('browse','misc-multispectral1');  % ISET Multispectral Image Database
ieWebGet('browse','misc-multispectral2');  % ISET Multispectral Image Database

% Collection is implemented, but a search works returns.  Ask Amy.
ieWebGet('browse','iset-hyperspectral-collection');
ieWebGet('browse','faces-1m');       % ISET Hyperspectral Image Database
ieWebGet('browse','faces-3m');       % ISET Hyperspectral Image Database
ieWebGet('browse','fruits-charts');  % ISET Hyperspectral Image Database
ieWebGet('browse','landscape-hyperspectral');  % ISET Hyperspectral Image Database

ieWebGet('browse','cone-fundamentals-paper');
ieWebGet('browse','isethdrsensor-paper');

%}
%{
localFile = ieWebGet('deposit name', 'pbrtv4','deposit file','kitchen.zip');
%}
%{
localFile = ieWebGet('deposit name', 'iset3d','deposit file','SimpleScene');
%}
%{
% Get this file, unzip it, remove the zip file
[localFile,zipFiles] = ieWebGet('deposit name', 'bitterli', ...
                       'deposit file','cornell-box', ...
                       'confirm',false,'unzip',true,'remove zip file',true);
%}
%{
localFile = ieWebGet('deposit name', 'misc-multispectral1');

%}
%{
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
    depositList = urlDeposit('all');

    fprintf('\Deposits\n=================\n\n');
    for ii=2:numel(depositList)
        fprintf('%s\n',depositList{ii});
    end
    fprintf('\n');
    localFile = depositList(:,1);
    return;
end

%------- browse --------
if isequal(ieParamFormat(varargin{1}),'browse')
    if numel(varargin) < 2, depositName = 'pbrtv4';
    else,                   depositName = varargin{2};
    end

    resource = urlDeposit(depositName);

    web(resource{3});
    localFile = '';
    return;
end

%%  Download

% Not often returned.  But 
zipfilenames = '';

varargin = ieParamFormat(varargin);
[~,validResources] = urlDeposit('all');

p = inputParser;
vFunc = @(x)(ismember(ieParamFormat(x),validResources));
p.addParameter('depositname', 'pbrtv4',vFunc);
p.addParameter('depositfile', '', @ischar);

p.addParameter('confirm', true, @islogical);
p.addParameter('unzip', true, @islogical);  % assume the user wants the resource unzipped, if applicable
p.addParameter('localname','',@ischar);     % Defaults to remote name
p.addParameter('removezipfile', true, @islogical);
p.addParameter('downloaddir','',@ischar);

p.parse(varargin{:});

depositName   = p.Results.depositname;
depositFile   = p.Results.depositfile;
downloaddir    = p.Results.downloaddir;
unZip          = p.Results.unzip;
removeZipFile  = p.Results.removezipfile;

confirm  = p.Results.confirm;
localFile = '';        % Default local file name

%% Download the resource

resource = urlDeposit(depositName);
depositURL = resource(4);

switch ieParamFormat(depositName)

    case {'pbrtv4','bitterli','iset3d-scenes'}
        % An example
        % s = ieWebGet('resource type','pbrtv4','resource file','kitchen.zip');
        % localFile = ieWebGet('deposit name', 'iset3d-scenes','deposit file','simplescene');

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
            warning('Making download directory: %s',downloadDir);
            mkdir(downloadDir);
        end

        % We should check if the zip is already in the name.
        [~,~,e] = fileparts(depositFile);
        if ~isequal(e,'.zip')
            remoteFileName = strcat(depositFile, '.zip');
        else, remoteFileName = depositFile;
        end
        remoteURL    = strcat(depositURL{1}, '/',remoteFileName);
        localFile    = fullfile(downloadDir, remoteFileName);

        if confirm
            fprintf('** Downloading to %s ** \n',localFile);
            proceed = confirmDownload(depositFile, localFile);            
            if proceed == false, return, end
        end

        try
            % The pbrt files are zip files.
            websave(localFile, remoteURL);
            if exist(localFile,'file'), fprintf('Download complete.\n'); 
            else, error('failed download.\n'); 
            end
        catch
            warning("Failed to retrieve: %s", depositURL);
            localFile = '';
        end

    case {'faces-3m'}
        % localFile = ieWebGet('deposit name','faces-3m','deposit file','montage.jpg');
        if isempty(depositFile) || isequal(depositFile,'all')
            % Download them all
            remoteFileName = {'ISET_loresfemale_1_6.zip','ISET_loresfemale_7_12.zip',...
                'ISET_loresmale_1_8.zip','ISET_loresmale_9_16.zip','ISET_loresmale_17_24.zip',...
                'ISET_loresmale_25_40.zip','montage.jpg'};
        else
            % Download the one requested.
            remoteFileName{1} = depositFile;
        end

        if isempty(downloaddir)
            downloadDir = fullfile(isetRootPath,'local','sdr','faces3m');
        end
        nFiles = numel(remoteFileName);
        for ii=1:nFiles
            remoteURL = strcat(depositURL{1}, '/',remoteFileName{ii});
            localFile = sdrSpectralDownload(remoteURL,remoteFileName{ii},downloadDir,confirm);
        end

    case {'faces-1m'}
        % localFile = ieWebGet('resource type','faces-1m','resource file','montage.jpg');
        if isempty(depositFile) || isequal(depositFile,'all')
            % Download them all
            remoteFileName = {
                'ISET_hiresfemale_1_4.zip','ISET_hiresfemale_5_8.zip','ISET_hiresfemale_9_13.zip',...
                'ISET_hiresmale_1_4.zip','ISET_hiresmale_5_8.zip','ISET_hiresmale_9_12.zip',...
                'montage.jpg'};
        else
            % Download the one requested.
            remoteFileName{1} = depositFile;
        end

        if isempty(downloaddir)
            downloadDir = fullfile(isetRootPath,'local','sdr','faces1m');
        end
        nFiles = numel(remoteFileName);
        for ii=1:nFiles
            remoteURL    = strcat(depositURL{1}, '/',remoteFileName{ii});
            localFile = sdrSpectralDownload(remoteURL,remoteFileName{ii},downloadDir,confirm);
        end        
    case {'hdr-images'}
        % localFile = ieWebGet('resource type','hdr-images');
        % All the SDR initialized resources from the Stanford Digital
        % Repository.  Not quite sure how we will manage in the end.
        remoteFileName = 'HDR.zip';
        if isempty(downloaddir)
            downloadDir = fullfile(isetRootPath,'local','sdr','hdr');
        end
        remoteURL    = strcat(depositURL{1}, '/',remoteFileName);
        localFile = sdrSpectralDownload(remoteURL,remoteFileName,downloadDir,confirm);

    case {'misc-multispectral2'}
        % All the SDR initialized resources from the Stanford Digital
        % Repository.  Not quite sure how we will manage in the end.
        remoteFileName = 'MultispectralDataset2.zip';
        if isempty(downloaddir)
            downloadDir = fullfile(isetRootPath,'local','sdr');
        end
        remoteURL    = strcat(depositURL{1}, '/',remoteFileName);
        localFile = sdrSpectralDownload(remoteURL,remoteFileName,downloadDir,confirm);

    case {'misc-multispectral1'}
        remoteFileName = 'MultispectralDataSet1.zip';
        if isempty(downloaddir)
            downloadDir = fullfile(isetRootPath,'local','sdr');
        end
        remoteURL    = strcat(depositURL{1}, '/',remoteFileName);
        localFile = sdrSpectralDownload(remoteURL,remoteFileName,downloadDir,confirm);

    case {'isethdrsensor'}
        if ~isempty(p.Results.downloaddir)
            % The user gave us a place to download to.
            downloadDir = p.Results.downloaddir;
        else
            % Go to local/sdr
            downloadDir = fullfile(isetRootPath,'local','sdr');
        end

        localFile = fullfile(downloadDir, depositFile);
        localDir  = fileparts(localFile);
        if ~isfolder(localDir), mkdir(localDir); end
        remoteURL = fullfile(baseURL,depositFile);
        try
            fprintf('*** Downloading %s from ISETHDRSensor SDR ... \n',depositFile);
            websave(localFile, remoteURL);
            fprintf('*** File is downloaded! \n');
        catch
            warning("Unable to retrieve %s", remoteURL);
        end
end


%% Download succeeded. Should we unzip it?  Remove the zip?
if unZip
    % localFile = ieWebGet('deposit file', 'chessset', 'deposit name','iset3d-scenes','unzip',true);
    zipfilenames = unzip(localFile,downloadDir);

    % The directory is the part before .zip
    idx = strfind(localFile,'.zip');

    if removeZipFile
        % After unzipping, we usually remove the zip.  The localFile
        % directory then becomes the local path, really.
        delete(localFile);
        localFile = localFile(1:(idx-1));
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

%---------urlDeposit----------
function [resource, validResources] = urlDeposit(depositName)
% Keep track of the URLs for browsing and downloading here.
%
% Resource name, SDR name, SDR purl, SDR data url
%
% See also
%

if notDefined('depositName'), depositName = 'all'; end

% Stored in an N x 4 cell array
%
% Resource name, SDR name, SDR purl, SDR data url
%
% For a nice print out:
%
%   disp(resourceCell)
%
resourceCell = {...
    'bitterli','ISET 3d Scenes bitterli', 'https://purl.stanford.edu/cb706yg0989', 'https://stacks.stanford.edu/file/druid:cb706yg0989/sdrscenes/bitterli';
    'pbrtv4',  'ISET 3d Scenes pharr', 'https://purl.stanford.edu/cb706yg0989',    'https://stacks.stanford.edu/file/druid:cb706yg0989/sdrscenes/pbrtv4';
    'iset3d-scenes', 'ISET 3d Scenes iset3d', 'https://purl.stanford.edu/cb706yg0989', 'https://stacks.stanford.edu/file/druid:cb706yg0989/sdrscenes/iset3d-scenes';
    'landscape-hyperspectral','ISET hyperspectral scene data for landscapes','https://purl.stanford.edu/dy318qn9992', 'https://stacks.stanford.edu/file/druid:dy318qn9992';
    'faces-3m','ISET scenes of faces at 3M', 'https://purl.stanford.edu/rr512xk8301','https://stacks.stanford.edu/file/druid:rr512xk8301';
    'faces-1m','ISET hyperspectral scenes of human faces at high resolution, 1M distance', 'https://purl.stanford.edu/jj361kc0271','https://stacks.stanford.edu/file/druid:jj361kc0271'
    'fruits-charts','ISET scenes with fruits and calibration charts','https://purl.stanford.edu/tb259jf5957', '';
    'people-multispectral','ISET multispectral scenes of people','https://purl.stanford.edu/mv668yq1424', '';
    'misc-multispectral1','ISET multispectral scenes of faces, fruit, objects, charts','https://purl.stanford.edu/sx264cp0814', 'https://stacks.stanford.edu/file/druid:sx264cp0814';
    'misc-multispectral2','ISET multispectral scenes of fruit, books, color calibration charts','https://purl.stanford.edu/vp031yb6470','https://stacks.stanford.edu/file/druid:vp031yb6470';
    'hdr-images','HDR Images of Natural Scenes','https://purl.stanford.edu/sz929jt3255','https://stacks.stanford.edu/file/druid:sz929jt3255';...
    'vistalab-collection','Vista Lab Collection','https://searchworks.stanford.edu/catalog?f[collection][]=qd500xn1572','';
    'iset-multispectral-collection','ISET Multispectral Image Database','https://searchworks.stanford.edu/view/sm380jb1849','';
    'iset-hyperspectral-collection','Not yet implemented','https://searchworks.stanford.edu/?search_field=search&q=ISET+Hyperspectral+Image+Database','';
    'cone-fundamentals-paper','Deriving the cone fundamentals','https://purl.stanford.edu/jz111ct9401','https://stacks.stanford.edu/file/druid:jz111ct9401/cone_fundamentals';
    'isethdrsensor-paper','ISET HDR Sensor', 'https://purl.stanford.edu/bt316kj3589', 'https://stacks.stanford.edu/file/druid:bt316kj3589/isethdrsensor'
    };

validResources = resourceCell(:,1);

if isequal(depositName,'all')
    % Return the cell arrays
    resource = resourceCell;
    return;
else
    % Find the matching one.
    idx = strcmp(validResources, ieParamFormat(depositName));
    % Maybe just contains, but for now a full match up the upper/lower and
    % spaces.
    % idx = contains(validResources,ieParamFormat(depositName));
    if isempty(idx)
        error('No matching resource: %s\n',depositName);
    end
    resource = resourceCell(idx,:);
end

end

% ----------sdrSpectralDownload----------
function localFile = sdrSpectralDownload(depositURL,remoteFileName,downloadDir,confirm)
%

if isempty(downloadDir) || ~isfolder(downloadDir), mkdir(downloadDir); end

localFile = fullfile(downloadDir, remoteFileName);
if confirm
    proceed = confirmDownload(remoteFileName, localFile);
    if proceed == false, return, end
end

try
    fprintf('Downloading ...')
    websave(localFile, depositURL);
    fprintf('done.\n');
catch
    warning("Unable to retrieve %s", depositURL);
end

end
