function depthmap = exiftoolDepthFromFile(fName, varargin)
%EXIFTOOLDEPTHFROMFILE Summary of this function goes here

% Check inputs
if notDefined('fName'), error('file name required'); end

% Set path to exiftool
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

fout = tempname;

opts1 = '-b -trailer ';
opts2 = '- -b -trailer > ';

[s, msg] = system(char([fp ' ' opts1 ' ' fName ' | ' fp ' ' opts2 fout]));

if s ~= 0, error(msg); end

% Load file
%fullimage = imread(fName); % we need this to scale the depth map to match
fImageInfo = imfinfo(fName);

depthmap = imread(fout);
depthmap = imresize(depthmap, [fImageInfo.Width, fImageInfo.Height]);

%map = [];

% Clean up
delete(fout);

end

