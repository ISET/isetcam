function img = imageSlantedEdge(imSize,slope, darklevel)
% Make a slanted edge image - always square and odd number of rows/cols
%
% Brief
%   This target is used for the ISO 12233 standard. By construction
%   the image size is always returned as odd. The bright side is
%   always 1. The dark level is a parameter.
%
% Synopsis
%   img = imageSlantedEdge(imSize,slope,darklevel);
%
% Inputs
%   imSize    - (row,col) (384,384) by default
%   slope     - slope of the edge (2.6 default)
%   darklevel - Dark side (0 default).  White side is always 1.
%
% Key/val pairs
%   N/A
%
% Outputs
%  img:   A slanted edge image with a slope at the edge.
%
% Description
%   The axes for an image start with (1,1) at the upper left.  So a
%   slope of 2.6 produces a line y = slope*x that becomes an image
%   with the edge sloping downwards.
%
% See also
%   sceneCreate('slanted edge')
%

% Examples:
%{
 img = imageSlantedEdge;
 ieNewGraphWin; imagesc(img);
 axis image; colormap(gray(64)); caxis([0 1]);
%}
%{
 img = imageSlantedEdge([256,128],8,0.8);
 ieNewGraphWin; imagesc(img); axis image; colormap(gray(64)); caxis([0 1])
 truesize;
%}

%% Parse
if ieNotDefined('imSize'),    imSize = [384,384]; end
if ieNotDefined('slope'),     slope = 2.6; end
if ieNotDefined('darklevel'), darklevel = 0; end

if numel(imSize) == 1, imSize(2) = imSize; end

%% Make the image

% We force the image size to be odd.

% This is even
imSize = round(imSize/2);   

% This is always odd
[X,Y] = meshgrid(-imSize(2):imSize(2),-imSize(1):imSize(1));

img = ones(size(X))*darklevel;

%  y = slope*x defines the line.  We find all the Y values that are
%  above the line
list = (Y > slope*X );

% We assume target is perfectly reflective (white), so the illuminant is
% the equal energy illuminant; that is, the SPD is all due to the
% illuminant
img( list ) = 1;

end

