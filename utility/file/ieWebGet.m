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
%  N/A
%
% Key/val pairs
%  op:            The operation to perform {'fetch','read','list','browse'}
%                 (default: 'fetch')
%  resource type: 'pbrt', 'hyperspectral', 'multispectral', 'hdr'
%                 (default: 'pbrt')
%  resource name: File name of the remote file
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
%   The types of resources are listed above.  To see the names of the
%   resources, use the 'list' operation.
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

%% Decode key/val args

varargin = ieParamFormat(varargin);

p = inputParser;
vFunc = @(x)(ismember(x, {'fetch', 'read', 'list', 'browse'}));
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

        baseURL = 'http://stanford.edu/~wandell/data/pbrt/';
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
            case 'browse'
                % assume for now that means we are listing
                web(baseURL);
                localFile = '';
            case 'list'
                % simply read the pre-loaded list of resources
                try
                    localFile = webread(strcat(baseURL, 'resourcelist.json'));
                catch
                    warning("Unable to load resource list");
                    localFile = '';
                end
        end
    case {'hyperspectral', 'multispectral', 'hdr'}

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
            case 'browse'
                web(baseURL);
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
                    case 'list'
                        % simply read the pre-loaded list of resources
                        try
                            localFile = webread(strcat(baseURL, 'resourcelist.json'));
                        catch
                            warning("Unable to load resource list");
                            localFile = '';
                            return
                        end
                        % we need to filter here as sometimes we only want .MAT
                        % files
                        localFile = localFile(ieContains(localFile, ".mat", 'IgnoreCase', true));
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
