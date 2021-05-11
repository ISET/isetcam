function [ratio] = pvReduction(overlap, numGrid, numGridSpot, diodeLocation, outsideAngle, OPTICS, PIXEL)
%
% Author: ImagEval, PC
% Purpose:
%   Simulate the efficiency reduction due to   Pixel Vignetting. The upper
% layer metal forms a deep  tunnel around the photodiode which is sitting
% at the bottom of the tunnel. The tunnel casts shadow for incident light.
%
% DATE: 08/02/99
% Setting up local variables
f = opticsGet(OPTICS, 'focallength'); % Focal Length [m]
D = opticsGet(OPTICS, 'diameter'); % Diameter [m]
w = pixelGet(PIXEL, 'width'); % Diode size [m]
h = pixelGet(PIXEL, 'depth'); %
% Distance from surface to diode [m]
% Now we try to find the real overlap region based on the center of
% diode and center of spot.
diodeCenterX = diodeLocation(:, 1);
diodeCenterY = diodeLocation(:, 2);
spotCenterX = (f - h) * tan(outsideAngle(:, 1));
spotCenterY = (f - h) * tan(outsideAngle(:, 2));
offsetX = (diodeCenterX - spotCenterX);
offsetY = (diodeCenterY - spotCenterY);
% Check this
indexOffsetX = round((offsetX/w)*numGrid);
indexOffsetY = round((offsetY/w)*numGrid);
indexCenterX = ((size(overlap, 2) - 1) / 2 + 1);
indexCenterY = ((size(overlap, 1) - 1) / 2 + 1);
indexRangeX = (indexCenterX - indexOffsetX + (-(numGrid - 1) / 2:(numGrid - 1) / 2));
indexRangeY = (indexCenterY - indexOffsetY + (-(numGrid - 1) / 2:(numGrid - 1) / 2));
% This sets the indices of the XY-range to (1,1), which is has a zero value, i.e. overlap(1,1) == 0;
indexRangeX(find(indexRangeX <= 0)) = 1;
indexRangeY(find(indexRangeY <= 0)) = 1;
indexRangeX(find(indexRangeX > size(overlap, 2))) = 1;
indexRangeY(find(indexRangeY > size(overlap, 1))) = 1;
overlap_ = overlap(indexRangeX, indexRangeY);
ratio = sum(overlap_(:));
return;