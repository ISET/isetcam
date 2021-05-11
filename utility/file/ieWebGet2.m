function localFile = ieWebGet(varargin)

%% Download a resource from the Stanford web site
%
% Synopsis
%   localFile = ieWebGet(varargin)
%
% Brief description
%  Download an ISET zip or mat-file file from the web.  The type of file
%  and the remote file name define how to get the file.
%
% Inputs
%   'browse','list','url' - If the first argument is one of these terms,
%   you will be sent to the website ('browse') or be returned a resources
%   list ('list'), or shown the web site urls ('url').  The second argument
%   defines the type of resource ('pbrt', 'hyperspectral', 'multispectral',
%   'hdr'). The default resource is 'pbrt'.
%
% Key/val pairs
%  op:            The operation to perform {'fetch','read'}
%                 (default: 'fetch')
%  resource type: 'pbrt', 'hyperspectral', 'multispectral', 'hdr'
%                 (default: 'pbrt')
%  resource name    :  File name of the remote file
%  remove temp files:  Remove local temp file (zip)
%  unzip:           :  Unzip the file
%  verbose          :  Print a report to the command window
%
% Output
%   localFile:  Name of the local download file
%
% Description
%   We store various data sets (resources) as zip- and mat-files on the
%   Stanford resource, cardinal.stanford.edu/~SOMEONE.  This routine is a
%   gateway that allows us to download the files (using fetch).
%
%   The types of resources are listed above.  To see the remote web site or
%   the names of the resources, use the 'list' or 'browse' operations.
%
% See also:
%    webImageBrowser_mlapp
%

% Examples
%{
% NOTE: pbrt scenes default to being stored under iset3d/data/v3/ if available, other
% scenes default to being stored under isetcam/local/scenes/<resourcetype>/.
%}
%{
% Browse the remote site
ieWebGet('browse');
%}
%{
ieWebGet('list')
%}
%{
localFile = ieWebGet('resource name','veach-ajar');
%}
%{
localFile       = ieWebGet('resourcename', 'ChessSet', 'resourcetype', 'pbrt')
data            = ieWebGet('op', 'read', 'resourcetype', 'hyperspectral', 'resourcename', 'FruitMCC')
localFile       = ieWebGet('op', 'fetch', 'resourcetype', 'hdr', 'resourcename', 'BBQsite1')
~               = ieWebGet('resourcetype', 'pbrt', 'op', 'browse')
%}
%{
% Use it to create a list of resources and then select one:
arrayOfResourceFiles = ieWebGet('op', 'list', 'resourcetype', 'hyperspectral')
data = ieWebGet('op', 'read', 'resource type', 'hyperspectral', 'resource name', arrayOfResourceFiles{ii});
%}

%% Set up base URL

urlList = ...
    {'http://stanford.edu/~wandell/data/pbrt/', ...
    'http://stanford.edu/~david81/ISETData/Hyperspectral/', ...
    'http://stanford.edu/~david81/ISETData/Multispectral/', ...
    'http://stanford.edu/~david81/ISETData/HDR/'};
baseURL = urlList{1};

%% Check for the special input arguments
% ieWebGet('browse','pbrt'),
% ieWebGet('browse','hyperspectral')
if ismember(ieParamFormat(varargin{1}), {'browse', 'list', 'url'})
    if numel(varargin) < 2, src = 'pbrt';
    else, src = ieParamFormat(varargin{2});
    end
    switch src
        case 'pbrt'
            baseURL = urlList{1};
        case 'hyperspectral'
            baseURL = urlList{2};

        case 'multispectral'
            baseURL = urlList{3};
        case 'hdr'
            baseURL = urlList{4};
        otherwise
            error('Unknown resource type %s\n', src);
    end
    if isequal(ieParamFormat(varargin{1}), 'browse')
        % assume for now that means we are looking on the web
        web(baseURL);
        localFile = '';
        return;
    elseif isequal(ieParamFormat(varargin{1}), 'list')
        % simply read the pre-loaded list of resources
        try
            localFile = webread(strcat(baseURL, 'resourcelist.json'));
        catch
            % We should find a better way to do this
            warning("Unable to load resource list from remote site. Returning webread data");
            localFile = webread(baseURL);
        end
        % we need to filter here as sometimes we only want .MAT files
        localFile = localFile(contains(localFile, ".mat", 'IgnoreCase', true));
        return;
    elseif isequal(ieParamFormat(varargin{1}), 'url')

        fprintf('\nResource URLs\n=================\n\n');
        for ii = 1:numel(urlList)
            fprintf('%s\n', urlList{ii});
        end
        fprintf('\n');
        return;
    end
end

%%  Decode key/val args
varargin = ieParamFormat(varargin);

p = inputParser;
vFunc = @(x)(ismember(x, {'fetch', 'read', 'list'}));
p.addParameter('op', 'fetch', vFunc);
p.addParameter('resourcename', '', @ischar);
vFunc = @(x)(ismember(x, {'pbrt', 'hyperspectral', 'multispectral', 'hdr', 'pbrt', 'v3'}));
p.addParameter('resourcetype', 'pbrt', vFunc);

p.addParameter('askfirst', true, @islogical);
p.addParameter('unzip', true, @islogical); % assume the user wants the resource unzipped, if applicable
p.addParameter('localname', '', @ischar); % Defaults to remote name
p.addParameter('removetempfiles', true, @islogical);
p.addParameter('verbose', true, @islogical); % Tell the user what happened

p.parse(varargin{:});

resourceName = p.Results.resourcename;
resourceType = p.Results.resourcetype;
localName = p.Results.localname;
unZip          = p.Results.unzip;
removeTempFiles = p.Results.removetempfiles;

if isempty(localName)
    localName = resourceName;
end
verbose = p.Results.verbose;
op = p.Results.op;
askFirst = p.Results.askfirst;
localFile = ''; % Default local file name

switch resourceType
    case {'pbrt', 'v3'}
        if exist('piRootPath', 'file') && isfolder(piRootPath)
            downloadRoot = piRootPath;
        elseif exist('isetRootPath', 'file') && isfolder(isetRootPath)
            downloadRoot = isetRootPath;
        else
            error("Need to have either iset3D or isetCam Root set");
        end

        switch op
            case 'fetch'
                % for now we only support v3 pbrt files
                downloadDir = fullfile(downloadRoot, 'data', 'v3');
                if ~isfolder(downloadDir)
                    mkdir(downloadDir);
                end

                remoteFileName = strcat(resourceName, '.zip');
                resourceURL = strcat(baseURL, remoteFileName);
                localURL = fullfile(downloadDir, remoteFileName);

                if askFirst
                    proceed = confirmDownload(resourceName, resourceURL, localURL);
                    if proceed == false, return, end
                end

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
            otherwise
                error('Unknown operation for PBRT %s\n', op);
                end

            case {'hyperspectral', 'multispectral', 'hdr'}

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
                        if ~endsWith(resourceName, "." +lettersPattern)
                            remoteFileName = strcat(resourceName, '.mat');
                        else
                            remoteFileName = resourceName;
                        end
                        resourceURL = strcat(baseURL, remoteFileName);
                        switch op
                            case {'fetch', 'read'}
                                if exist('isetRootPath', 'file') && isfolder(isetRootPath)
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
                                        proceed = confirmDownload(resourceName, resourceURL, localFile);
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
                        error('sceneType %s not supported.', resourceType);
                end

                %% Tell the user what happened
                if verbose
                    if ischar(localFile)
                        disp(strcat("Retrieved: ", resourceName, " to: ", localFile));
                    elseif isstruct(localFile)
                        disp(strcat("Retrieved: ", resourceName, " and returned as a struct"));
                    elseif exist('localFile', 'file') && ~isempty(localFile)
                        disp(strcat("Retrieved: ", resourceName, " and returned it as an array"));
                    elseif ~isequal(op, 'list')
                        disp(strcat("Unable to Retrieve: ", resourceName));
                    end
                end

        end

        %% Query the user to confirm the download
        %
        function proceed = confirmDownload(resourceName, resourceURL, localURL)
            question = sprintf("Okay to download: %s from %s to file %s and if necessary, unzip it?\n This may take some time.", resourceName, resourceURL, localURL);
                answer = questdlg(question, "Confirm Web Resource Download", 'Yes');
                if isequal(answer, 'Yes')
                    proceed = true;
                else
                    proceed = false;
                end
            end
