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

fprintf('ISET root directory: %s\n', isetDir)

% Adds the root directory of the ISET tree to the user's path
addpath(isetDir);

% Generates a list of the directories below the ISET tree and adds them.
addpath(genpath(isetRootPath));

% Remove paths related to version control.
vcs_dirs = {'.git', '.svn'};
for i = 1:length(vcs_dirs)
    vcs_path = fullfile(isetRootPath, vcs_dirs{i});
    if ~isempty(dir(vcs_path));
        rmpath(vcs_path);
    end
end

% Refreshes the path.
path(path);

return;
