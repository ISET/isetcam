function md5Mex
% Compile the md5.cpp file into a mex file for this platform
%
%    md5Mex
%
% The mex file is placed in the dll70 directory.  The user is informed
% about the name and location of the md5 file.  This file is essential for
% license verification.
%
% Users may need to run
%
%    mex -setup
%
% to make sure that the Matlab C-compiler is available on the path.
%
% See ieInstall for a full management of the MEX files
%
% Copyright ImagEval Consultants, LLC, 2008.

%TODO:  This has worked many times.  But there can be a problem with the
%compiler installation.
%

chdir(fullfile(isetRootPath,'utility','dll70','md5'));
mex md5.cpp
movefile(['md5.',mexext],fullfile(isetRootPath,'utility','dll70',['md5.',mexext]))
path(path)
fprintf('The md5 for your system is %s\n',which('md5'))

return;
