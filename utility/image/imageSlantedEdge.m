function img = imageSlantedEdge(imSize, slope)
% Make a slanted edge binary image
%
% Syntax
%   img = imageSlantedEdge(imSize,slope);
%
% Description
%   Create a slanted edge image (0s and 1s).  Useful for resolution
%   testing.
%
% Inputs
%   imSize - (row,col) (384,384) by default
%   slope  - slope of the edge (2.6 default)
%
% Key/val pairs
%   N/A
%
% Outputs
%  img:   A binary slanted edge image with a slope at the edge.
%
% JEF/BW 2019
%
% See also
%   sceneCreate('slanted edge')
%

% Examples:
%{
img = imageSlantedEdge;
ieNewGraphWin; imagesc(img);
axis image; colormap(gray)
%}
%{
img = imageSlantedEdge([256,128],2.3);
ieNewGraphWin; imagesc(img); axis image; colormap(gray)
truesize;
%}

%% Parse
if ieNotDefined('imSize'), imSize = [384, 384]; end
if ieNotDefined('slope'), slope = 2.6; end

if numel(imSize) == 1, imSize(2) = imSize; end

%% Make the image
imSize = round(imSize/2);
[X, Y] = meshgrid(-imSize(2):imSize(2), -imSize(1):imSize(1));

img = zeros(size(X));

%  y = slope*x defines the line.  We find all the Y values that are
%  above the line
list = (Y > slope * X);

% We assume target is perfectly reflective (white), so the illuminant is
% the equal energy illuminant; that is, the SPD is all due to the
% illuminant
img(list) = 1;

end
