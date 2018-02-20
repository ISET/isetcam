function rectHandles = chartRectsDraw(sensor,rects)
% Draw the ROI rectangles as an overlay on the object window
%
%   rectHandles = chartRectsDraw(sensor,rects)
%
% Inputs:
%   sensor:  Object.  Only sensor for now
%   rects:   Nx4 matrix of rectangle positions for ROIs
%
% Returns:
%   rectHandles:  Object handles for rectangle overlays
%
% (c) Imageval Consulting, LLC 2012


% Find corners of the rectangles.  Should be a function.  Used in
% ieRoi2Locs, also.  Possibly other places
cmin = rects(:,1); cmax = rects(:,1)+rects(:,3);
rmin = rects(:,2); rmax = rects(:,2)+rects(:,4);

% Closed rectangles
nRects = size(rects,1);
rectHandles = zeros(nRects,1);

a = get(sensorImageWindow,'CurrentAxes');

c = cell(nRects,1);
for ii=1:nRects
    c{ii} = ...
        [cmin(ii),rmin(ii);
        cmax(ii),rmin(ii);
        cmax(ii),rmax(ii);
        cmin(ii),rmax(ii);
        cmin(ii),rmin(ii)];
end

for ii=1:nRects
    hold(a,'on');
    rectHandles(ii) = plot(a,c{ii}(:,1),c{ii}(:,2),'Color',[1 1 1], 'LineWidth',2);
end
hold(a,'off')

end

