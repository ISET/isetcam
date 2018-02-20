function isetPath(isetDir)
% Set Matlab directory path for ISET
%
%     isetPath(isetDir)
%
% Set up the path to the functions and data called by ISET.  Place this
% function in a location that is in the Matlab path at start-up.  When
% you wish to initialize the ISET path, or add a path for one of the
% tools boxes, call this function.
%
% Many people simply change to the ISET root directory and type
% isetPath(pwd)
%
% Another possibility is to include the ISET root directory on your
% path, and then invoke isetPath(isetRootPath).
%
% We recommend against putting the entire ISET distribution on your path,
% permanently. The reason is this:  Future distributions may change a
% directory organization. In that case, you may get path errors or other
% problems when you change distributions.
%
% Examples:
%   isetDir = 'c:\myhome\Matlab\ISET'; isetPath(isetDir);
%   cd c:\myhome\Matlab\ISET;          isetPath(pwd);
%
% copyfileright ImagEval Consultants, LLC, 2003.

fprintf('ISET root directory: %s\n',isetDir)

% Adds the root directory of the ISET tree to the user's path
addpath(isetDir);

% Generates a list of the directories below the ISET tree.
p = genpath(isetRootPath);

% Adds all of the directories to the user's path.
addpath(p);

% Refreshes the path.
path(path);

% For people using the svn version - ask for: svnRemovePath;
% to eliminate the svn directories from the matlab path.

% We must have the proper DLL on the path.  This depends on the version
% number.  We may need to elaborate this section of the code in the future.
version = ver('Matlab');
v = version.Version(1:3);
versionNumber = str2num(v);

if versionNumber < 7, error('ISET requires version 7 or higher'); end

return;
