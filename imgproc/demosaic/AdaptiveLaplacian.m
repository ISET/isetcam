function [ rgb ] = AdaptiveLaplacian( bayer_in, bPattern, clipToRange)
% Adaptive laplacian demosaicking algorithm
%
%  RGB = AdaptiveLaplacian( BAYER, bPattern, clipToRange )
%
% Demosaicking algorithms estimate missing color information by
% interpolation of the known color information across different color
% planes.  
% 
% Interpolation is performed only in the direction with the smallest
% gradient. If the gradient is high, the algorithm does not average across
% the border.
%
% The multiple color band functions like this can have out of range values
% (beyond 0,1).  Normally, we clip to range.  You can turn this off by
% setting clipToRange = 0 
%
% Copyright ImagEval Consultants, LLC, 2005.

% This code is designed for grbg.  To make it work on other forms,  we run
% the mosaicConverter, which transforms several other non-grbg forms into
% grbg.
%
% This is only implemented for RGB mosaics.  It should not be run on CMY or
% 4-color sensors.  The data should be checked. It should be extended. 
%
% The code is unattractive.  And it is hard to debug/understand.  

if ieNotDefined('bayer_in'), error('Bayer rgb data required.'); end
if ieNotDefined('bPattern'), error('Bayer pattern info required.'); end
if ieNotDefined('clipToRange'), clipToRange = 1; end 

% mosaicConverter transforms non-grbg into grbg.  This is the only format
% that works for the remaining part of the code.
[bayer_in, bPattern] = mosaicConverter(bayer_in,bPattern);

V = size(bayer_in,1);
H = size(bayer_in,2);

% Mirror the data around the border, making bayer extended.  Notice that
% the extension assumes that the pattern is 2x2.  So the extension is
% really of the block.  We should be sure to shrink the output image when
% we are done!  I don't think that is happening yet.
bayer_ex = [bayer_in(:,3:4,:) bayer_in bayer_in(:,(H-3):(H-2),:)];
bayer_ex = [bayer_ex(3:4,:,:);bayer_ex;bayer_ex((V-3):(V-2),:,:)];

% Two points added at each side, so 4 extra points total.  These are used
% for calculating sums and differences.  The output, however, is the same
% size as the input.
Vex = V+4;
Hex = H+4;

% Set known pixels.
rgb(:,:,1) = bayer_in(:,:,1);  % Red pixel
rgb(:,:,2) = bayer_in(:,:,2);  % Green1 & Green2 pixels
rgb(:,:,3) = bayer_in(:,:,3);  % Blue pixel

% Determine positions of the various types of color pixels;
% bayer_ex(ry,rx,1) is a good image.
% These indices are designed to address the internal part of the bayer_ex
% mosaic, so we start the indices 2 in and we stop the indices 2 from the
% edge
%
[rx, ry ,bx ,by, g1x, g1y, g2x, g2y] = ...
    bayerIndices(bPattern,[Vex,Hex],2);
%  figure; imtool(bayer_ex(g1y,g1x,2))

% Red pixels: Set green values
% Compute the difference and sum across nearby green pixels.
gdH = bayer_ex(g1y,g1x,2) - bayer_ex(g1y,g1x+2,2);
gdV = bayer_ex(g2y,g2x,2) - bayer_ex(g2y-2,g2x,2);

gsH = bayer_ex(g1y,g1x,2) + bayer_ex(g1y,g1x+2,2);
gsV = bayer_ex(g2y,g2x,2) + bayer_ex(g2y-2,g2x,2);

% Compute the difference between each red pixel and the average of its
% horizontal or vertical neighbors.
rH  = 2*bayer_ex(ry,rx,1) - bayer_ex(ry,rx-2,1) - bayer_ex(ry,rx+2,1);
rV  = 2*bayer_ex(ry,rx,1) - bayer_ex(ry-2,rx,1) - bayer_ex(ry+2,rx,1);

% Make a kind of gradient for the green and red terms combined, in both the
% horizontal and vertical directions.
deltaH = abs( gdH ) + abs( rH );
deltaV = abs( gdV ) + abs( rV );
% figure; mesh(deltaV)

% In this operation, one of three conditions is true.  The rgb value is set
% to a value depending on which condition holds.  In principle, the user
% should be able to set weights on the conditions -- or adjust the range
% over which each operates in some way.
rgb(ry-2,rx-2,2) = ...
    (deltaH  < deltaV) .* ( 0.50*gsH + 0.25*rH ) + ...
    (deltaH  > deltaV) .* ( 0.50*gsV + 0.25*rV ) + ...
    (deltaH == deltaV) .* ( 0.25*(gsH+gsV) + 0.125*(rH+rV) );
% l = zeros(size(deltaH));
% l(deltaH < deltaV) = 1; l(deltaH > deltaV) = 2;l(deltaH == deltaV) = 3;
% figure; imshow(l,eye(3))

% Blue pixels: Set green values
gdH = bayer_ex(g2y,g2x,2) - bayer_ex(g2y,g2x-2,2);
gdV = bayer_ex(g1y,g1x,2) - bayer_ex(g1y+2,g1x,2);

gsH = bayer_ex(g2y,g2x,2) + bayer_ex(g2y,g2x-2,2);
gsV = bayer_ex(g1y,g1x,2) + bayer_ex(g1y+2,g1x,2);

bH  = 2*bayer_ex(by,bx,1) - bayer_ex(by,bx-2,1) - bayer_ex(by,bx+2,1);
bV  = 2*bayer_ex(by,bx,1) - bayer_ex(by-2,bx,1) - bayer_ex(by+2,bx,1);

deltaH = abs( gdH ) + abs( bH );
deltaV = abs( gdV ) + abs( bV );

% In this operation, one of three conditions is true.  The rgb value is set
% to a value depending on which condition holds.
rgb(by-2,bx-2,2) = ...
    (deltaH  < deltaV) .* ( 0.50*gsH + 0.25*bH ) + ...
    (deltaH  > deltaV) .* ( 0.50*gsV + 0.25*bV ) + ...
    (deltaH == deltaV) .* ( 0.25*(gsH+gsV) + 0.125*(bH+bV) );

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

rdN = bayer_ex(ry,rx-2,1) - bayer_ex(ry+2,rx,1);
rdP = bayer_ex(ry,rx,1) - bayer_ex(ry+2,rx-2,1);

rsN = bayer_ex(ry,rx-2,1) + bayer_ex(ry+2,rx,1);
rsP = bayer_ex(ry,rx,1) + bayer_ex(ry+2,rx-2,1);

gN  = 2*bayer_ex(by,bx,2) - bayer_ex(ry,rx-2,2) - bayer_ex(ry+2,rx,2);
gP  = 2*bayer_ex(by,bx,2) - bayer_ex(ry,rx,2) - bayer_ex(ry+2,rx-2,2);

deltaN = abs( rdN ) + abs( gN );
deltaP = abs( rdP ) + abs( gP );

% In this operation, one of three conditions is true.  The rgb value is set
% to a value depending on which condition holds.
rgb(by-2,bx-2,1) = ...
    (deltaN  < deltaP) .* ( 0.50*rsN + 0.25*gN ) + ...
    (deltaN  > deltaP) .* ( 0.50*rsP + 0.25*gP ) + ...
    (deltaN == deltaP) .* ( 0.25*(rsN+rsP) + 0.125*(gN+gP) );

% Red pixels: Set blue value

bdN = bayer_ex(by-2,bx,3) - bayer_ex(by,bx+2,3);
bdP = bayer_ex(by,bx,3) - bayer_ex(by-2,bx+2,3);

bsN = bayer_ex(by-2,bx,3) + bayer_ex(by,bx+2,3);
bsP = bayer_ex(by,bx,3) + bayer_ex(by-2,bx+2,3);

gN  = 2*bayer_ex(ry,rx,2) - bayer_ex(by-2,bx,2) - bayer_ex(by,bx+2,2);
gP  = 2*bayer_ex(ry,rx,2) - bayer_ex(by,bx,2) - bayer_ex(by-2,bx+2,2);

deltaN = abs( bdN ) + abs( gN );
deltaP = abs( bdP ) + abs( gP );

% In this operation, one of three conditions is true.  The rgb value is set
% to a value depending on which condition holds.
rgb(ry-2,rx-2,3) = ...
    (deltaN  < deltaP) .* ( 0.50*bsN + 0.25*gN ) + ...
    (deltaN  > deltaP) .* ( 0.50*bsP + 0.25*gP ) + ...
    (deltaN == deltaP) .* ( 0.25*(bsN+bsP) + 0.125*(gN+gP) );

if clipToRange, rgb = ieClip(rgb); end

return;
