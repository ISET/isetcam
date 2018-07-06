function artifacts = rdtDownload(rd, varargin)
%% Download folder and zip the files from remote data server
%   files = rdtDownload(rd, varargin)
%
% Required inputs:
%   rd        - remote data object
%
% Optional parameters:
%   rdPath    - remote data path, the folder or file to be downloaded.
%               Default is rd.pwrp
%   localPath - the path to store the downloaded file on local disk.
%               Default is current folder
%   isZip     - bool, indicate whether to zip the downloaded folder.
%               When isZip is true, the downloaded files are deleted after
%               zipping. Default value is true
%   verbose   - bool, indicate whether to print debug information.
%               Default is true
%
% Outputs:
%   artifacts - artifacts structure array
%
% Notes:
%   If folder structure is not important, you can use rdt.readArtifacts to
%   download all the files
%
% Example:
%   rd = RdtClient('scien');
%   files = rdtDownload(rd, 'rdPath', '/L3/faces', 'isZip', false);
%   files = rdtDownload(rd, 'rdPath', '/L3/faces');
%
% HJ, VISTA TEAM, 2016

%% Parse inputs
p = inputParser();
p.addRequired('rd');
p.addParameter('rdPath', rd.pwrp);
p.addParameter('localPath', pwd, @isdir);
p.addParameter('isZip', true, @islogical);
p.addParameter('verbose', true, @islogical);

p.parse(rd, varargin{:});

% remote path
cwrp = rd.pwrp;
rd.crp(p.Results.rdPath);
assert(~isempty(rd.listArtifacts), 'remote path not exist or empty');

% local path
cwd = cd(p.Results.localPath);

% parameters
isZip = p.Results.isZip;
verbose = p.Results.verbose;

%% Download files
%  make local folder
[~, folderName, ~] = fileparts(rd.pwrp);
if exist(folderName, 'dir'), error('directory already exist'); end
[s, msg] = mkdir(folderName);
assert(s, msg);
cd(folderName);

%  download files
artifacts = rd.listArtifacts();
for ii = 1 : length(artifacts)
    if verbose
        fprintf('Downloading %d/%d: %s...\n', ...
            ii, length(artifacts), artifacts(ii).artifactId);
    end
    lp = artifacts(ii).remotePath(length(rd.pwrp)+1:end);
    if isempty(lp), lp = '.'; end
    rd.readArtifact(artifacts(ii).artifactId, ...
        'type', artifacts(ii).type, ...
        'destinationFolder', lp);
end

%  zip
if isZip
    cd('..');
    zip([folderName '.zip'], folderName);
    rmdir(folderName, 's');
end

%% Clean up
% return to previous working directory
cd(cwd);
rd.crp(['/' cwrp]);

end