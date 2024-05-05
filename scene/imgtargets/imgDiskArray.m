function img = imgDiskArray(imgSize,diskRadius,arraySize)
% Monochrome image of an array of squares
%
% Brief
%   Part of the system testing images, like ramp, sweep, and so forth.
%
% Synopsis
%   img = imgDiskArray(imgSize, diskRadius,arraySize)
%
% Input
%   imgSize      - In pixels
%   diskRadius   - In pixels
%   arraySize    - row,col number of squares
%
% Output
%   img - Monochrome image that can be transformed into a hyperspectral
%   scene
%
% See also
%   imgSquareArray, imgRamp

% Example:
%{
   img = imgDiskArray(512,16,[3 3]);
   ieNewGraphWin; imagesc(img); axis image
   img = imgDiskArray(1024,64,[2 4]);
   ieNewGraphWin; imagesc(img); axis image
   img = imgDiskArray(1024,256,[1 1]);
   ieNewGraphWin; imagesc(img); axis image
%}

%% Parameters
if ieNotDefined('imgSize'),      imgSize = 512; end
if ieNotDefined('diskRadius'),   diskRadius = 16; end
if ieNotDefined('arraySize'),    arraySize = [1 1]; end

% Main images
img = zeros(imgSize);

[X,Y] = meshgrid(-diskRadius:diskRadius,-diskRadius:diskRadius);
disk = (sqrt(X.^2 + Y.^2) < diskRadius);

%% Space the squares in the image

% Pixel spacing between squares is the n squares + 1 divided into the size
% of the image.
deltaRow = round(imgSize/(arraySize(1)+1));
deltaCol = round(imgSize/(arraySize(2)+1));

% Upper left positions for the square
rowPositions = (deltaRow:deltaRow:(imgSize-(deltaRow-1))) - round(diskRadius);
colPositions = (deltaCol:deltaCol:(imgSize-(deltaCol-1))) - round(diskRadius);
[X,Y] = meshgrid(rowPositions,colPositions);
positions = [X(:),Y(:)];

% We use this to place the disk into the image
locs = (0:(diskRadius*2));

% For each position, put the disk in the image
for pp=1:numel(X)
    img(positions(pp,1) + locs, positions(pp,2) + locs) = disk;    
end

end
