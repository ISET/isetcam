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

if ~isfile(fout)
    depthmap = [];
    return
end

% Load file
%fullimage = imread(fName); % we need this to scale the depth map to match
fImageInfo = jsondecode(exiftoolInfo(fName, 'format', 'json'));

depthmap = imread(fout);

% we are assuming our depth map is uint8 
depthMax = 255;

switch fImageInfo.DepthMapUnits
    case 'Meters'
        farMeters = fImageInfo.DepthMapFar;
        nearMeters = fImageInfo.DepthMapNear;
        depthmap = nearMeters + (single(depthmap)./depthMax .* (farMeters - nearMeters));  
    case 'Diopters'
        % assume rangeinverse for now?
        % need to calculate actual diopters
        minDiopters = fImageInfo.DepthMapNear;
        maxDiopters = fImageInfo.DepthMapFar;

        % this assumes a regular range map
        %diopterMap = minDiopters + (single(depthmap)./depthMax .* (maxDiopters - minDiopters));  

        % what about an inverse range map
        diopterMap = maxDiopters - (single(depthmap)./depthMax .* (maxDiopters - minDiopters));  

        depthmap = 1./diopterMap;
        
    otherwise % assume meters?
        % do nothing
        farMeters = fImageInfo.DepthMapFar;
        nearMeters = fImageInfo.DepthMapNear;
end


%may need to rotate depthmap
%or at least correct proportions when it isn't rotated and image is

switch fImageInfo.Orientation
    case 1
        % we're fine
        depthmap = imresize(depthmap, [fImageInfo.ImageWidth, fImageInfo.ImageHeight]);
    case 'Rotate 90 CW'
        depthmap = imrotate(depthmap, -90);
        depthmap = imresize(depthmap, [fImageInfo.ImageWidth, fImageInfo.ImageHeight]);        
    case 'Rotate 90 CCW'
        depthmap = imrotate(depthmap, 90);
        depthmap = imresize(depthmap, [fImageInfo.ImageWidth, fImageInfo.ImageHeight]);
    otherwise
        depthmap = imresize(depthmap, [fImageInfo.ImageWidth, fImageInfo.ImageHeight]);

end


%map = [];

% Clean up
delete(fout);

end

