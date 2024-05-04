function img = imgSquareArray(imgSize,squareSize,arraySize)
% Monochrome image of an array of squares
%
% Brief
%   Part of the system testing images, like ramp, sweep, and so forth.
%
% Synopsis
%   img = imgSquareArray(imgSize, squareSize,arraySize)
%
% Input
%   imgSize    - In pixels
%   squareSize - In pixels
%   arraySize  - row,col number of squares
%
% Output
%   img - Monochrome image that can be transformed into a hyperspectral
%   scene
%
% See also
%   imgDiskArray, imgRamp

% Example:
%{
   img = imgSquareArray(512,16,[3 3]);
   ieNewGraphWin; imagesc(img); axis image
   img = imgSquareArray(1024,64,[2 4]);
   ieNewGraphWin; imagesc(img); axis image
   img = imgSquareArray(1024,256,[1 1]);
   ieNewGraphWin; imagesc(img); axis image
%}

%% Parameters
if ieNotDefined('imgSize'), imgSize = 512; end
if ieNotDefined('squareSize'), squareSize = 16; end
if ieNotDefined('arraySize'), arraySize = [1 1]; end

% Main images
img = zeros(imgSize);
square = ones(squareSize);

%% Space the squares in the image

% Pixel spacing between squares is the n squares + 1 divided into the size
% of the image.
deltaRow = round(imgSize/(arraySize(1)+1));
deltaCol = round(imgSize/(arraySize(2)+1));

% Upper left positions for the square
rowPositions = (deltaRow:deltaRow:(imgSize-(deltaRow-1))) - round(squareSize/2);
colPositions = (deltaCol:deltaCol:(imgSize-(deltaCol-1))) - round(squareSize/2);
[X,Y] = meshgrid(rowPositions,colPositions);
positions = [X(:),Y(:)];

% We use this to place the square into the image
locs = (0:(squareSize-1));

% For each position, put the square in the image
for pp=1:numel(X)
    img(positions(pp,1) + locs, positions(pp,2) + locs) = square;    
end

end
