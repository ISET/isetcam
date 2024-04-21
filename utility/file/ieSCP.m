function [command,status] = ieSCP(user,host,src,destinationPath,varargin)
% Remote copy a file or directory.
%
% Synopsis
%    [command,status] = ieSCP(user,host,src,destinationPath,varargin)
%
% Description
%   Uses scp to securely copy a file or a folder from a remote machine.
%   NOTE:  Folder copy is not implemented and tested.  
%
% Input
%   user - user name
%   host - remote system name (e.g., orange.stanford.edu)
%   src  - a filename or a directory name
%   destinationPath - the destination folder
%
% Optional
%   folder - Copy a folder, not a file (default false)
%   quiet  - Suppress printout to command window
%
% See also
%   s_autoLightGroups (isetauto)

% Example:
%{
  % Just the metadata file
  user = 'wandell';
  host = 'orange.stanford.edu';
  src  = '/acorn/data/iset/isetauto/Ford/SceneMetadata/1114091636.mat';
  destPath = pwd;
  ieSCP(user,host,src,destPath,'quiet',false);
%}
%{
  % The metadata and the rendered images
  user = 'wandell';
  host = 'orange.stanford.edu';
  
  % Prepare the local directory  
  imageID = '1114091636';
  destPath = fullfile(iaRootPath,'local',imageID);
  if ~exist(destPath,'dir'), mkdir(destPath); end

  % First the metadata
  src  = fullfile('/acorn/data/iset/isetauto/Ford/SceneMetadata',[imageID,'.mat']);
  ieSCP(user,host,src,destPath);
  load(fullfile(destPath,[imageID,'.mat']),'sceneMeta');

  % Now the four light group EXR files
  lgt = {'headlights','streetlights','otherlights','skymap'};
  for ll = 1:numel(lgt)
     thisFile = sprintf('%s_%s.exr',imageID,lgt{ll});
     srcFile  = fullfile(sceneMeta.datasetFolder,thisFile); 
     destFile = fullfile(destPath,thisFile);
     ieSCP(user,host,srcFile,destFile);
  end

%}

%% Input args

varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('user',@ischar);
p.addRequired('host',@ischar);
p.addRequired('src',@ischar);    % Remote file or remote folder
p.addRequired('destinationPath',@ischar);

p.addParameter('folder',false,@islogical);  % Download the whole folder
p.addParameter('quiet',false,@islogical);

p.parse(user,host,src,destinationPath,varargin{:});

%% Construct the SSH command for scp
flags = '';
if p.Results.folder, flags = [flags,' -r']; end
if p.Results.quiet,  flags = [flags,' -q']; end

command = ['scp ',flags, ' ', user, '@', host, ':', src, ' ', destinationPath];

% Execute the command using system
status = system(command);

if status == 0
  if ~p.Results.quiet, disp('File copied successfully!'); end
else
  disp('Error during remote secure copy. Check connection and paths.');
end

end
