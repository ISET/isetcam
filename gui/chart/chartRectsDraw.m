function rectHandles = chartRectsDraw(obj,rects)
% Draw the ROI rectangles as an overlay on the object window
%
%   rectHandles = chartRectsDraw(obj,rects)
%
% Inputs:
%   obj:     scene, oi, sensor or ip
%   rects:   Nx4 matrix of rectangle positions.  Each row of rects is a
%            standard rect format, [colMin,rowMin,width,height].
%
% Returns:
%   rectHandles:  Object handles for rectangle overlays
%
% (c) Imageval Consulting, LLC 2012
%
% See also:
%   chartRectangles, chartCornerpoints, sceneRadianceChart


%% Find corners of the rectangles.  

% Maybe this should edited to use ieRect2Vertices
cmin = rects(:,1) - 1; cmax = rects(:,1)+rects(:,3) - 1;
rmin = rects(:,2) - 1; rmax = rects(:,2)+rects(:,4) - 1;

% These are the graphical handles for the rects we will draw
nRects = size(rects,1);

% These are the rect parameters for drawing, below.  Awkward how these are
% cells and such.  Could simplify.
c = cell(nRects,1);
for ii=1:nRects
    c{ii} = ...
        [cmin(ii),rmin(ii);
        cmax(ii),rmin(ii);
        cmax(ii),rmax(ii);
        cmin(ii),rmax(ii);
        cmin(ii),rmin(ii)];
end

%% Draw the rects.  Multiple rects can be sent in

rectHandles = ieDrawShape(obj,'rectangle',round(rects));

end

