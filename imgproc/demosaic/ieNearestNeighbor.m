function [ rgb ] = ieNearestNeighbor(bayer, bPattern)
%Nearest neighbor demosaicking
%
%   RGB = ieNearestNeighbor(BAYER, [bPattern = 'gbrg'])
%
% Demosaicking algorithms estimate missing color information by
% interpolation of the known color information across different color
% planes.
%
% This algorithm replicates the color information that is closest to the
% missing information.  This implementation only works for grbg bayer
% patterns.
%
%
% Copyright ImagEval Consultants, LLC, 2005.

% Programming TODO:
%  Must be fixed to work for rggb and perhaps others.
%  Programming style needs to be updated.  See Adaptive Laplacian.

if ieNotDefined('bayer'), error('Bayer mosaic required.'); end
if ieNotDefined('bPattern'), bPattern = 'rggb'; end

V   = size(bayer,1);
H   = size(bayer,2);
out = zeros(V,H);

[rx, ry ,bx ,by, g1x, g1y, g2x, g2y] = bayerIndices(bPattern,[V,H]);

% Set red component.

% red = bayer(1:2:V,2:2:H,1);
red    = bayer(ry,rx,1);             % figure; imshow(3*red)
green1 = bayer(g1y,g1x,2);
green2 = bayer(g2y,g2x,2);           % figure; imshow(3*green2)
blue   = bayer(by,bx,3);             % figure; imshow(3*blue)

% Initialize the good data points
rgb = bayer;

if isodd(ry(1)), dy = 1; else dy = -1; end
if isodd(rx(1)), dx = 1; else dx = -1; end
rgb(ry,rx+dx,  1)  = red;
rgb(ry+dy,rx,  1)  = red;
rgb(ry+dy,rx+dx,1) = red;         % figure; imshow(3*rgb)

% Set green component.
% rgb(    :,    :,2) = bayer(:,:,2);
if isodd(g1x(1)), dx = 1; else dx = -1; end
rgb(g1y,g1x+dx,2) = green1;
rgb(g2y,g2x-dx,2) = green2;

% Set blue component.
% rgb(    :,    :,3) = bayer(:,:,3);
if isodd(by(1)), dy = 1; else dy = -1; end
if isodd(bx(1)), dx = 1; else dx = -1; end
rgb(by,bx+dx,3)    = blue;
rgb(by+dy,bx,3)    = blue;
rgb(by+dy,bx+dx,3) = blue;

return;
