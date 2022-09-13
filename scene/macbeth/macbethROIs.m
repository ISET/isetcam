function [patchLocs, rect] = macbethROIs(currentLoc,delta)
% Derive the locations within a rect region of interest for an MCC chart
%
% Synopsic
%  [patchLocs, rect] = macbethROIs(currentLoc,delta)
%
% Description
%
%   Create the rects from the center of an MCC patch. The spacing between
%   the centers is delta.  The format of a rect is
%
%     (colMin,rowMin,width,height).
%
%   The patchLocs is a matrix of N (row,col).
%
% Input:
%   currentLoc - The center of the patch
%   delta -      The size of the rect
%
% Return
%   patchLocs - The locations within the rect, derived by ieRect2Locs
%   rect - The rect
%
% See also:
%   macbethRectangles, macbethDrawRects, macbethSensorValues, ieRect2Locs
%

if ieNotDefined('currentLoc'), error('current location in MCC required'); end
if ieNotDefined('delta'), delta = 10; end  % Get a better algorithm for size

rect(1) = currentLoc(2) - round(delta/2);
rect(2) = currentLoc(1) - round(delta/2);
rect(3) = delta;
rect(4) = delta;

patchLocs = ieRect2Locs(rect);

end
