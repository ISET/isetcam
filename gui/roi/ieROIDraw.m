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
%  isetobj:  Type of object ('scene','oi','sensor','ip', or 'display')
%
% Key/val pairs
%  shape:    Type of shape  ('rect')
%  shape data:  Values needed to draw the shape
%       rect = [row col width height]
%       color
%       linewidth
%       linestyle
%
% Outputs
%  shapeHandle: Shape with its parameters
%  ax:           Current axes of the ISET object window
%
% See also
%   chartROI, chartRectangles, macbethROIs
%  

% Examples:
%{
scene = sceneCreate;
rect = [1 50 10 5];  % row, col, width, height
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

varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('isetobj',@ischar);
p.addParameter('shape','rect',@ischar);
p.addParameter('shapedata',[1 1 5 5],@isnumeric);
p.addParameter('color','w',@ischar);
p.addParameter('linewidth',2,@isnumeric);
p.addParameter('linestyle','-',@ischar);

p.parse(isetobj,varargin{:});
shape = p.Results.shape;

%% Get the current axis for that iset object type

switch isetobj
    case 'scene'
        ax = get(sceneWindow,'CurrentAxes');
    case 'oi'
        ax = get(oiWindow,'CurrentAxes');
    case 'sensor'
        ax = get(sensorImageWindow,'CurrentAxes');
    case 'ip'
        ax = get(ipWindow,'CurrentAxes');
    case 'display'
        ax = get(displayWindow,'CurrentAxes');
    otherwise
        error('Unknown iset object type %s\n',isetobj);
end

%% Draw the shape

switch shape
    case 'rect'
        rect = p.Results.shapedata;
        shapeHandle = rectangle(ax,'Position',rect);
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
        
        th = 0:pi/50:2*pi;
        xunit = radius * cos(th) + x;
        yunit = radius * sin(th) + y; hold on;
        shapeHandle = plot(ax,xunit, yunit);
    otherwise
        error('Unknown shape %s\n',shape);
end


end
