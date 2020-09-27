function rawInfo = dcrawInfo(fname)
% Query raw image for various parameters, returned in text
%
% Inputs:
%   fname - path to image to be loaded
% Outputs:
%   rawInfo - text of various parameters
%
% Example:
%   I = dcrawRead('DSC01354.ARW');
%
% See also:
%   dcrawInit
% 

% Check inputs
if notDefined('fname'), error('file name required'); end

% Decode file
if ismac
    fp = fullfile(L3rootpath, 'external', 'dcraw', 'dcraw_mac');
elseif isunix
    fp = fullfile(L3rootpath, 'external', 'dcraw', 'dcraw_linux');
elseif ispc
    fp = fullfile(L3rootpath, 'external', 'dcraw', 'dcraw_win64');
else
    error('If you are on Win32, use dcraw_win32.');
end

opts = '-i -v';
[~, rawInfo] = system([fp ' ' opts ' ' fname]);

end