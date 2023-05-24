function wvfRoot=wvfRootPath()
% Return the path to the root wavefront optics toolbox directory
%
% Syntax:
%   wvfRoot = wvfRootPath
%
% Description:
%    This function must reside in the directory at the base of the
%    Wavefront Optics Tolbox directory structure. It is used to determine
%    the location of various sub-directories.
% 
% Inputs:
%    None.
%
% Outputs:
%    wvfRoot - The path to the root wavefront optics toolbox
%
% Optional key/value pairs:
%    None.
%

% Examples:
%{
   wvfRoot = wvfRootPath
%}

wvfRoot = which('wvfRootPath');
wvfRoot = fileparts(wvfRoot);

return