function status = ieSCP(user,host,src,destinationPath)
% Remote copy a file 
%
% Description
%   We securely copy a file or a folder from a remote machine.
%
% Input
%   user - user name
%   host - remote system name (e.g., orange.stanford.edu)
%   src  - a filename or a directory name
%   destinationPath - the destination folder
%
% Optional
%   folder - Copy a folder, not a file (default false)
%
% See also
%

%% Replace with username, hostname, source and destination paths
%{
username = 'your_username';
hostname = 'linux_machine_name';
sourcePath = '/remote/folder/filename.txt';
destinationPath = '/local/folder/';
%}

%% Construct the SSH command for scp

if p.Results.folder
    command = ['scp -r ' user '@' host ':' src ' ' destinationPath];
else
    command = ['scp ' user '@' host ':' src ' ' destinationPath];
end

% Execute the command using system
status = system(command);

if status == 0
  disp('File copied successfully!');
else
  disp('Error during copy. Check connection and paths.');
end
