function roiLocs = ieRect2Locs(rect)
% Convert a rect from an ISET window into region of interest locations.
%
% Synopsis
%   roiLocs = ieRect2Locs(rect)
%
% Description
%   The rect is usually selected selected using the Matlab graphical user
%   interface. In most cases the rect values are:
%
%     [colMin rowMin (width-1) (height-1)].
%
%   In some cases, more modern ones, the rect is sometimes a Matlab
%   Rectangle object and round(rect.Positions) are the rect.
%
%   Usually we call the routine ieROISelect directly, which might then call
%   this routine.
%
% (c) Imageval, 2004
%
% See also:
%  ieROISelect, ieLocs2Rect
%

if isa(rect,'images.roi.Rectangle')
    rect = round(rect.Position);
end

% The rect entries are (colMin,rowMin,colWidth-1,rowWidth-1)
% The number of data values are colMax - colMin + 1 and similarly for the
% row
cmin = rect(1); cmax = rect(1)+rect(3);
rmin = rect(2); rmax = rect(2)+rect(4);

[c,r] = meshgrid(cmin:cmax,rmin:rmax);
roiLocs = [r(:),c(:)];

end