function depthmap = exiftoolDepthFromFile(fName, varargin)
%EXIFTOOLDEPTHFROMFILE Pulls depth maps from some images

%{
    A number of smartphones and cameras, including recent model Google
    Pixel cameras can optionally record depth information in the form of a
    depth map alongside the main image.

    Google has published a spec for its version, called Dynamic Depth
    Format. Unfortunately, it leaves a number of pieces up to the
    implementation. We have been able to read out the depth map using Phil
    Harvey's amazing Exiftool, and take a stab at interpreting its
    RangeInverse encoding to come up with something in meters that ISET can
    use.

    However, it doesn't seem quite right yet. Perhaps there is some scaling
    factor related to it using diopters as the unit of distance? The task
    is to use some 'ground truth' images and scenes to see if you can sort
    out the rest of the encoding and get a sense of how and when the
    depthmaps are accurate or useful.
%}

% Check inputs
if notDefined('fName'), error('file name required'); end

% Set path to exiftool
if ismac
    error("No exiftool setup for Mac yet. Someone needs to download & check in.");
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

depthmap = single(imread(fout));

% we are assuming our depth map is uint8
depthMax = 255;

textDistance = split(fImageInfo.SubjectDistance, ' '); % by default is in text
subjectDistance = single(str2double(textDistance{1}));
subjectDiopters = 1/subjectDistance;

minDiopters = 0;
maxDiopters = 0;

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
        %diopterMap = maxDiopters - (single(depthmap)./depthMax .* (maxDiopters - minDiopters));
        %depthmap = 1./diopterMap;
        
        % Code from Google doc on RangeInverse
        % Source: https://developers.google.com/depthmap-metadata/encoding
        
        far = maxDiopters; % maybe should be 1/for meters
        near = minDiopters; % maybe should be 1/for meters
        farnear = far * near; % not sure if this should really be converted to meters
        farminusnear = far - near; % also maybe should be meters?
        dNormal = single(depthmap) ./ depthMax;
        dCalc = farnear ./ (far - dNormal * farminusnear);
        depthmap = dCalc;
        
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
        depthmap = imresize(depthmap, [fImageInfo.ImageHeight, fImageInfo.ImageWidth]);
    case 'Rotate 90 CW'
        %depthmap = imrotate(depthmap, -90);
        depthmap = imresize(depthmap, [fImageInfo.ImageHeight, fImageInfo.ImageWidth]);
    case 'Rotate 90 CCW'
        %depthmap = imrotate(depthmap, 90);
        depthmap = imresize(depthmap, [fImageInfo.ImageHeight, fImageInfo.ImageWidth]);
    otherwise
        depthmap = imresize(depthmap, [fImageInfo.ImageHeight, fImageInfo.ImageWidth]);
        
end


%map = [];

% Clean up
delete(fout);

end

