function [shapeHandle,ax] = ieROIDraw(isetobj,varargin)
% Draw a shape in the main axis window of an ISETCam object
%
% Syntax
%   [shapeHandle,ax] = ieROIDraw(isetobj,varargin)
%
% Describe
%   Gateway routine for drawing regions of interest (ROI) on an ISET
%   window.
%
% Inputs:
%  isetobj:  An ISETCam object type ('scene','oi','sensor','ip', or
%       'display') or just the string.  If just the string, (e.g., 'ip')
%       then the routine gets the currently selected object from the
%       database environment.
%
% Key/val pairs:
%  shape:    Type of shape  ('rect', 'circle','line')
%  parameters for all the shapes
%       color
%       linewidth
%
%  parameters for rect:
%     rect = [row col width height]
%     linestyle
%     curvature (at the corners of the rect, default is 0.2)
%
%  parameters for circle
%
%  parameters for line
%
% Outputs
%  shapeHandle: Shape with its parameters
%  ax:           Current axes of the ISET object window
%
% ieExamplesPrint('ieROIDraw');
%
% See also
%   chartROI, chartRectangles, macbethROIs
%

% Examples:
%{
 scene = sceneCreate;
 rect = [20 50 10 5];  % row, col, width, height
 [shapeHandle,ax] = ieROIDraw('scene','shape','rect','shape data',rect,'line width',5);
 shapeHandle.LineStyle = ':';
 delete(shapeHandle);
%}
%{
 rect = [50 50 20 20];
 [shapeHandle,ax] = ieROIDraw('oi','shape','rect','shape data',rect,'line style',':');
 shapeHandle.LineStyle = ':';
 shapeHandle.EdgeColor = 'w';
 delete(shapeHandle);
%}
%{
 c = [10 20 20];
 [shapeHandle,ax] = ieROIDraw('oi','shape','circle','shape data',c);
 shapeHandle.LineStyle = ':';
 shapeHandle.EdgeColor = 'w';
 delete(shapeHandle);
%}
%{
 c = [1 88 70 70];
 [shapeHandle,ax] = ieROIDraw('ip','shape','line','shape data',c);
%}

%%
varargin = ieParamFormat(varargin);

p = inputParser;
vFunc = @(x)(ischar(x) || (isstruct(x) && isfield(x,'type')));
p.addRequired('isetobj',vFunc);
p.addParameter('shape','rect',@ischar);
p.addParameter('shapedata',[1 1 5 5],@isnumeric);
p.addParameter('color','w',@ischar);
p.addParameter('linewidth',2,@isnumeric);
p.addParameter('linestyle','-',@ischar);
p.addParameter('curvature',0.2,@isnumeric);

p.parse(isetobj,varargin{:});
shape = p.Results.shape;

%% Draw the shape
[~,ax] = ieAppGet(isetobj);
if ~isvalid(ax), error('Object %s axis is not valid.',isetobj.type); end

switch shape
    case {'rect','rectangle'}
        rect = p.Results.shapedata;
        
        % I don't use this because it doesn't allow
        % LineStyle
        %   shapeHandle = drawrectangle(ax,'Position',rect);
        %
        shapeHandle = rectangle(ax,'Position',rect,'Curvature',p.Results.curvature);
        shapeHandle.EdgeColor = p.Results.color;
        shapeHandle.LineWidth = p.Results.linewidth;
        shapeHandle.LineStyle = p.Results.linestyle;
        
    case 'circle'
        % shape data [r row col]
        % r =  radius
        % row = y coordinates of the center
        % col = x coordinates of the center
        radius = p.Results.shapedata(1);
        x = p.Results.shapedata(3);
        y = p.Results.shapedata(2);
        shapeHandle = drawcircle(ax,'Radius',radius,'Center',[x y]);
        %{
        th = 0:pi/50:2*pi;
        xunit = radius * cos(th) + x;
        yunit = radius * sin(th) + y; hold on;
        shapeHandle = plot(ax,xunit, yunit);
        %}
    case 'line'
        % shape data for a line are two points on the line
        % [x1 x2 y1 y2]
        pts = p.Results.shapedata;
        shapeHandle = line(pts(1:2),pts(3:4));
        shapeHandle.Color = p.Results.color;
        shapeHandle.LineWidth = p.Results.linewidth;
        shapeHandle.LineStyle = p.Results.linestyle;
    otherwise
        error('Unknown shape %s\n',shape);
end


end
