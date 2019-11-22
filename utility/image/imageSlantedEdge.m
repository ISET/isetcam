function img = imageSlantedEdge(imSize,slope)
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
%   imSize
%   slope
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
 img = imageSlantedEdge(128,1);
 ieNewGraphWin; imagesc(img); axis image; colormap(gray)
 truesize;
%}

%% Parse
if ieNotDefined('imSize'),   imSize = 384; end
if ieNotDefined('slope'),    slope = 2.6; end

%% Make the image
imSize = round(imSize/2);
[X,Y] = meshgrid(-imSize:imSize,-imSize:imSize);
img = zeros(size(X));

%  y = slope*x defines the line.  We find all the Y values that are
%  above the line
list = (Y > slope*X );

% We assume target is perfectly reflective (white), so the illuminant is
% the equal energy illuminant; that is, the SPD is all due to the
% illuminant
img( list ) = 1;

end

