function rectHandles = chartRectsDraw(obj,rects)
% Draw the ROI rectangles as an overlay on the object window
%
%   rectHandles = chartRectsDraw(sensor,rects)
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
%   chartRectangles, sceneRadianceChart

%% Should check input parameters here!
%

%% Find corners of the rectangles.  

% Should be a function.  Used in ieRoi2Locs, also.  Possibly other places
cmin = rects(:,1); cmax = rects(:,1)+rects(:,3);
rmin = rects(:,2); rmax = rects(:,2)+rects(:,4);

% These are the graphical handles for the rects we will draw
nRects = size(rects,1);
rectHandles = zeros(nRects,1);

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

% The handle to the axis in the window
switch obj.type 
    case 'scene'
        a = get(sceneWindow,'CurrentAxes');
    case 'opticalimage'
        a = get(oiWindow,'CurrentAxes');
    case 'sensor'
        a = get(sensorImageWindow,'CurrentAxes');
    case 'vcimage'
        a = get(ipWindow,'CurrentAxes');
    otherwise
        disp('Unknown object %s\n',obj.type);
end

% Draw the rects
for ii=1:nRects
    hold(a,'on');
    rectHandles(ii) = plot(a,c{ii}(:,1),c{ii}(:,2),'Color',[1 1 1], 'LineWidth',2);
end
hold(a,'off')

end

