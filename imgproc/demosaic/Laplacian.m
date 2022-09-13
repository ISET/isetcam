function [ rgb ] = Laplacian( bayer_in, bPattern, clipToRange)
% Laplacian demosaicing algorithm
%
%   RGB = Laplacian( bayerData, bPattern, [clipToRange] )
%
% Demosaic'ing algorithms estimate missing color information by
% interpolation of the known color information across different color
% planes.
%
% This is a non-adaptive version of AdaptiveLaplacian.
%
% bayerData:   Sensor mosaic data
% bPattern:    Type of Bayer pattern ('grbg') assumed.
% clipToRange: The multiple color band functions like this can have out of
%              range values (beyond 0,1).  You can force the data to be
%              within (0,1) by setting the input argument, clipToRange =
%              true;
%
% Copyright ImagEval Consultants, LLC, 2005.

% Default is to produce output between 0 and 1
if ieNotDefined('bPattern'), bPattern = 'grbg'; end
if ieNotDefined('clipToRange'), clipToRange = false; end

% mosaicConverter transforms non-grbg into grbg.  This is the only format
% that works for the remaining part of the code.
[bayer_in, bPattern] = mosaicConverter(bayer_in,bPattern);

% Calculations are based on a 0,1 input, also
if max(bayer_in(:) > 1), bayer_in = ieScale(bayer_in,1); end

V = size(bayer_in,1);
H = size(bayer_in,2);

% Mirror the data around the border.
% bayer_ex is bayer extended.  It has four additional pixels in each direction
% to manage data near the edges.
bayer_ex = [bayer_in(:,3:4,:) bayer_in bayer_in(:,(H-3):(H-2),:)];
bayer_ex = [bayer_ex(3:4,:,:);bayer_ex;bayer_ex((V-3):(V-2),:,:)];
Vex = V+4;
Hex = H+4;

% Set known pixels.

rgb(:,:,1) = bayer_in(:,:,1);  % Red pixel
rgb(:,:,2) = bayer_in(:,:,2);  % Green1 & Green2 pixels
rgb(:,:,3) = bayer_in(:,:,3);  % Blue pixel

% [rx, ry ,bx ,by, g1x, g1y, g2x, g2y] = bayerIndices(Hex,Vex,bPattern);
[rx, ry ,bx ,by, g1x, g1y, g2x, g2y] = ...
    bayerIndices(bPattern,[Vex,Hex],2);

%  vcNewGraphWin; imtool(bayer_ex(g1y,g1x,2))

% Red pixels: Set green values
gsH = bayer_ex(g1y,g1x,2) + bayer_ex(g1y,g1x+2,2);
gsV = bayer_ex(g2y,g2x,2) + bayer_ex(g2y-2,g2x,2);

rH  = 2*bayer_ex(ry,rx,1) - bayer_ex(ry,rx-2,1) - bayer_ex(ry,rx+2,1);
rV  = 2*bayer_ex(ry,rx,1) - bayer_ex(ry-2,rx,1) - bayer_ex(ry+2,rx,1);

rgb(ry-2,rx-2,2) = ( 0.25*(gsH+gsV) + 0.125*(rH+rV) );

% Blue pixels: Set green values

gsH = bayer_ex(g2y,g2x,2) + bayer_ex(g2y,g2x-2,2);
gsV = bayer_ex(g1y,g1x,2) + bayer_ex(g1y+2,g1x,2);

bH  = 2*bayer_ex(by,bx,1) - bayer_ex(by,bx-2,1) - bayer_ex(by,bx+2,1);
bV  = 2*bayer_ex(by,bx,1) - bayer_ex(by-2,bx,1) - bayer_ex(by+2,bx,1);

rgb(by-2,bx-2,2) = ( 0.25*(gsH+gsV) + 0.125*(bH+bV) );

% The next part of the algorithm depends on these interpolated green values.
% Hence, we must re-mirror the green values around the border.

grn = [rgb(:,3:4,2) rgb(:,:,2) rgb(:,(H-3):(H-2),2)];
grn = [ grn(3:4,:) ; grn(:,:) ; grn((V-3):(V-2),:) ];

bayer_ex(:,:,2) = grn;

% Green pixels: Set red values

rgb(g1y-2,g1x-2,1) = 0.5*(bayer_ex(ry,rx,1) + bayer_ex(ry,rx-2,1)) + ...
    0.25*(2*bayer_ex(g1y,g1x,2)-bayer_ex(ry,rx-2,2)-bayer_ex(ry,rx,2));

rgb(g2y-2,g2x-2,1) = 0.5*(bayer_ex(ry,rx,1) + bayer_ex(ry+2,rx,1)) + ...
    0.25*(2*bayer_ex(g2y,g2x,2)-bayer_ex(ry+2,rx,2)-bayer_ex(ry,rx,2));

% Green pixels: Set blue values

rgb(g2y-2,g2x-2,3) = 0.5*(bayer_ex(by,bx,3) + bayer_ex(by,bx+2,3)) + ...
    0.25*(2*bayer_ex(g2y,g2x,2)-bayer_ex(by,bx+2,2)-bayer_ex(by,bx,2));

rgb(g1y-2,g1x-2,3) = 0.5*(bayer_ex(by,bx,3) + bayer_ex(by-2,bx,3)) + ...
    0.25*(2*bayer_ex(g1y,g1x,2)-bayer_ex(by-2,bx,2)-bayer_ex(by,bx,2));

% Blue pixels: Set red value

rsN = bayer_ex(ry,rx-2,1) + bayer_ex(ry+2,rx,1);
rsP = bayer_ex(ry,rx,1) + bayer_ex(ry+2,rx-2,1);

gN  = 2*bayer_ex(by,bx,2) - bayer_ex(ry,rx-2,2) - bayer_ex(ry+2,rx,2);
gP  = 2*bayer_ex(by,bx,2) - bayer_ex(ry,rx,2) - bayer_ex(ry+2,rx-2,2);

rgb(by-2,bx-2,1) = ( 0.25*(rsN+rsP) + 0.125*(gN+gP) );

% Red pixels: Set blue value

bsN = bayer_ex(by-2,bx,3) + bayer_ex(by,bx+2,3);
bsP = bayer_ex(by,bx,3) + bayer_ex(by-2,bx+2,3);

gN  = 2*bayer_ex(ry,rx,2) - bayer_ex(by-2,bx,2) - bayer_ex(by,bx+2,2);
gP  = 2*bayer_ex(ry,rx,2) - bayer_ex(by,bx,2) - bayer_ex(by-2,bx+2,2);

rgb(ry-2,rx-2,3) = ( 0.25*(bsN+bsP) + 0.125*(gN+gP) );

if clipToRange, rgb = ieClip(rgb); end

end

