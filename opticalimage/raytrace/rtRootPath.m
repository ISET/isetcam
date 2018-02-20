function rootPath = rtRootPath
%Return root directory of the ray trace code
%
%    dir = rtRootPath;
%
% Use this routine to find the base directory of the ray trace code.
% We could check for a license in this rouitine, too.
%
% Copyright ImagEval Consultants, LLC, 2007.

rootPath=which('rtRootPath');

rootPath=fileparts(rootPath);

return;
