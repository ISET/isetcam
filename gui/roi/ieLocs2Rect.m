function rect = ieLocs2Rect(roiLocs)
% Convert roi locs to rect format
%
%  rect = ieLocs2Rect(roiLocs)
%
% rect is a 1x4 spec of a rectangle [colMin rowMin (cWidth-1) (rWidth-1)]
% roiLocs is an Nx2 matrix of (r,c) values
%
% Example
%  roiLocs = ieLocs2Rect([ 2 4 9 7]);
%  rect = ieLocs2Rect(roiLocs)
%  roiLocs2 = ieLocs2Rect(rect);
%  isequal(roiLocs,roiLocs2)
%
% See also:
%   ieGetXYCoords, ieRect2Locs, vcROISelect, vcLineSelect, vcPointSelect
%
% (c) Imageval Consulting, LLC 2012

if size(roiLocs) ~= 2
    error('Expecting roiLocs as Nx2');
end

rect = zeros(1, 4);

% cMin and rMin
rect(1) = min(roiLocs(:, 2));
rect(2) = min(roiLocs(:, 1));

% cWidth and rWidth
rect(3) = max(roiLocs(:, 2)) - rect(1);
rect(4) = max(roiLocs(:, 1)) - rect(2);

end
