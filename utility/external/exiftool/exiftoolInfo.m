function exifInfo = exiftoolInfo(fname, varargin)
% Query image for various parameters, returned in text
%
% Inputs:
%   fname - path to image to be loaded
% Outputs:
%   exifInfo - text of various parameters
%
% Example:
%   I = exiftoolInfo('DSC01354.JPG');
%
% See also:
%   ??
% 

% Check inputs
if notDefined('fname'), error('file name required'); end

varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('format','text');
p.parse(varargin{:});

format = p.Results.format;

% Decode file
if ismac
    error("No exiftool setup for Mac yet");
    %fp = fullfile(isetRootPath,'utility', 'external', 'exiftool', 'exiftool_mac');
elseif isunix
    fp = fullfile(isetRootPath,'utility', 'external', 'exiftool', 'exiftool');
elseif ispc
    fp = fullfile(isetRootPath, 'utility', 'external', 'exiftool', 'exiftool.exe');
else
    error('Not sure what OS you are on or which exiftool to run');
end

if isequal(format, 'json')
    opts = '-json';
else
    opts = '-v';
end

[~, exifInfo] = system([fp ' ' opts ' ' fname]);

end