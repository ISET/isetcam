function roiLocs = ieRoi2Locs(rect)
% ******    Deprecated:  Call ieRect2Locs    *****
%
%  roiLocs = ieRoi2Locs(rect)
%
% Convert rectangle coordinates into roi locations.  The rect format is
%
%    (column,row,width,height).
%
% The first data point is drawn from the position [col,row].
%
% The roiLocs are a Nx2.  The roiLocs have rows in the first column and
% columns in the 2nd.
%
% For unfortunate historical reasons, which could be fought here, the
% spatial size of the returned data are width+1 and height+1. Thus,
% [col,row,1,1] returns four positions. [col,row,0,0] returns 1 position.
% Blame it on C and Fortran. Or me.
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also:
%   vcROISelect(), ieLocs2Rect
%

warning('Call ieRect2Locs, not ieRoi2Locs.  This routine is deprecated.');
roiLocs = ieRect2Locs(rect);

end

%{
% The rect entries are  The number of data
% values are colMax - colMin +1 and similarly for the row
cmin = rect(1); cmax = rect(1)+rect(3);
rmin = rect(2); rmax = rect(2)+rect(4);

[c,r] = meshgrid(cmin:cmax,rmin:rmax);
roiLocs = [r(:),c(:)];

return;
%}