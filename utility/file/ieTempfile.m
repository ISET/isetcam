function [fullname, p]  = ieTempfile(ext)
% Create a temporary ISET file 
%
%  [fullname, tempdir] = ieTempfile(ext)
%
% Creates a file name for the temporary file system.  An ie_ is prepended
% to the file in case you want to find it later.
%
% ext:  Extension to add to the file name
%
% fullname is the full path to the temporary file
% tempdir  is the directory where the temporary file is stored
%
% Example
%  f = ieTempfile('mat')
%  f = ieTempfile
%
% Copyright Imageval Consulting, 2015

[p,n] = fileparts(tempname);

if ieNotDefined('ext'),  ext = ''; end

fullname = fullfile(p,['ie_',n ,'.', ext]);

end
