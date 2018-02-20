function patchLocs = macbethROIs(currentLoc,delta)
%Derive a rect region of interest for an MCC chart
%
%  patchLocs = macbethROIs(currentLoc,delta)
%
% Find all the locations for a patch centered at the currentLoc and with a
% spacing of delta.  The format of a rect is (colMin,rowMin,width,height).
% The patchLocs is a matrix of N (row,col).
%
% See also: macbethRectangles, macbethDrawRects, macbethSensorValues
%
% Copyright ImagEval Consultants, LLC, 2011.

if ieNotDefined('currentLoc'), error('current location in MCC required'); end
if ieNotDefined('delta'), delta = 10; end  % Get a better algorithm for size

rect(1) = currentLoc(2) - round(delta/2);
rect(2) = currentLoc(1) - round(delta/2);
rect(3) = delta;
rect(4) = delta;

patchLocs = ieRoi2Locs(rect);

return;

