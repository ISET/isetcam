function [I, map] = dcrawRead(fname, opts, varargin)
% Load raw image data
%
%   [I, map] = dcrawRead(fname, [opts])
%
% Inputs:
%   fname - path to image to be loaded
%   opts  - opts to be applied to dcraw
%
% Outputs:
%   I   - loaded image
%   map - not used, put it here to be consistent of imread requirement
%
% Example:
%   I = dcrawRead('DSC01354.ARW');
%   vcNewGraphWin; imshow(I);
%
%   base = 'http://scarlet.stanford.edu/validation/SCIEN/L3/SonyRX100';
%   I = imread([base '/Landscape/DSC01354.ARW'], 'ARW');
%   vcNewGraphWin; imshow(I);
%
% Note:
%   1) This function is linked as read function for a bunch of raw camera
%      format in dcrawInit. Thus, if the api needs to be changed, remember 
%      to change dcrawInit also.
%   2) By dcrawInit, this function is called by imread. For loading images
%      specifying url, the image format field is required. Otherwise,
%      MATLAB will treat ARW file as TIFF and decoding will fail.
%
% See also:
%   dcrawInit
% 
% HJ, VISTA TEAM, 2015

% Check inputs
if notDefined('fname'), error('file name required'); end
if exist(fname, 'file') ~= 2, error('file not exist'); end
if notDefined('opts'), opts = '-o 0 -D -c -4'; end

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

fout = tempname;
[s, msg] = system([fp ' ' opts ' ' fname ' > ' fout]);

if s ~= 0, error(msg); end

% Load file
I = imread(fout);
map = [];

% Clean up
delete(fout);

end