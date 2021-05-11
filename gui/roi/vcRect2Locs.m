function roiLocs = vcRect2Locs(rect)
% Obsolete.  Use ieRect2Locs
%
% Convert a rect from an ISET window into region of interest locations.
%
%   roiLocs = vcRect2Locs(rect)
%
% The rect is usually selected selected using the Matlab grphical user
% interface. The rect values are:
%     [colMin rowMin (width-1) (height-1)].
% (Note that col is the x dimension and row is the y dimension).
%
% See also: vcROISelect(), ieLocs2Rect
%
% Example:
%   rect = round(getrect(ieSessionGet('ipwindow')));
%   roiLocs = ieRect2Locs(rect);
%
% Usually we call the routine vcROISelect directly, which calls this
% routine:
%   vci = vcGetObject('vcimage');
%   [roiLocs roiRect] = vcROISelect(vci);
%
%
% See also:  Uh oh, there is a routine ieROI2Locs which looks pretty much
% like this one.
%
% (c) Imageval, 2004

% The rect entries are (colMin,rowMin,colWidth-1,rowWidth-1)
% The number of data values are colMax - colMin + 1 and similarly for the
% row
cmin = rect(1);
cmax = rect(1) + rect(3);
rmin = rect(2);
rmax = rect(2) + rect(4);

[c, r] = meshgrid(cmin:cmax, rmin:rmax);
roiLocs = [r(:), c(:)];

return;