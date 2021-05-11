function rootPath = dll70Path
%Returns the root of the dll directory for Matlab 7
%
%   rootPath = dll70Path
%
%  This routine is used to determine which dll's should be on the path or
%  off.  If the user has Matlab 6.5, this path is removed.  If the user has
%  Matlab 7 or higher, this path is included.
%
% Copyright ImagEval Consultants, LLC, 2005.

tmp = which('dll70Path');

[rootPath, fName, ext] = fileparts(tmp);

return;