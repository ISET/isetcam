function roiLocs = ieRect2Locs(rect)
% Convert a rect from an ISET window into region of interest locations. 
%
%   roiLocs = ieRect2Locs(rect)
%
% The rect is usually selected selected using the Matlab grphical user
% interface. The rect values are:
%
%     [colMin rowMin (width-1) (height-1)].  
%
% (Note that col is the x dimension and row is the y dimension).
%
% Example:
%   rect = round(getrect(ieSessionGet('ipwindow')));
%   roiLocs = ieRect2Locs(rect);
%   
% Usually we call the routine ieROISelect directly, which calls this
% routine:
%
% (c) Imageval, 2004
%
% See also:
%  ieROISelect, ieLocs2Rect
%

% The rect entries are (colMin,rowMin,colWidth-1,rowWidth-1) 
% The number of data values are colMax - colMin + 1 and similarly for the
% row 
cmin = rect(1); cmax = rect(1)+rect(3);
rmin = rect(2); rmax = rect(2)+rect(4);

[c,r] = meshgrid(cmin:cmax,rmin:rmax);
roiLocs = [r(:),c(:)];

end