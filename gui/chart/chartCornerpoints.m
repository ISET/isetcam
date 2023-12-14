function [cornerPoints, obj, rect] = chartCornerpoints(obj,wholeChart)
% Return the outer corner points of a chart from sensor or ip window
%
% Syntax:
%    [cornerPoints, obj, rect] = chartCornerpoints(obj,wholeChart)
%
% Description:
%  The user selects the four corner points we need to define the positions
%  of the chart patches.  Graphical selection in the ip or sensor window.
%
%  The order is always lower left, lower right, upper right and upper left.
%  This ordering arises from MCC work.  Maybe it should be upper left and
%  then clockwise by option, some day.
%
%  If the whole image is the chart, set the wholeChart parameter to true.
%  Default is false.
%
% Inputs:
%   obj:  ISET object (scene, oi, sensor, ip)
%   wholeChart:  No GUI interaction; the whole image is the chart.
%               (default is false).
%
% Outputs:
%   cornerPoints:  Matrix (4x2) in (col,row), i.e. (x,y) format.
%   obj:           The cornerpoints are attached to the object.
%   rect:          Rect to use for cropping
%
% Copyright Imageval LLC, 2014
%
% See also:
%   chartROI, chartRectangles, chartRectsDraw


% Examples:
%{
  % For this to autorun to completion, can't ask for user input.
  % So set second argument to chartCornerpoints true here. Set to
  % false to see user select behavior.
  scene = sceneCreate; 
  sceneWindow(scene);
  scene = ieGetObject('scene');
  cp = chartCornerpoints(scene,true);
  [rects,mLocs,pSize] = chartRectangles(cp,4,6,0.5);  % MCC parameters
  chartRectsDraw(scene,rects);
%}
%{
  scene = sceneCreate;  camera = cameraCreate('default');
  camera = cameraCompute(camera,scene);
  cameraWindow(camera,'ip'); 
  ip = cameraGet(camera,'ip');
  cp = chartCornerpoints(ip,true);
  sFactor = 0.3;
  [rects, mLocs, pSize] = chartRectangles(cp, 4,6, sFactor);
  rectHandles = chartRectsDraw(ip,rects);
%}

%%
if ieNotDefined('obj'), error('Scene,oi,sensor or ip object required.'); end
if ieNotDefined('wholeChart'), wholeChart = false; end

if ~wholeChart
    % Make sure this is the selected object.
    ieRefreshWindow(obj.type);
    nPoints = 4;
    
    % The user selects corner points in the window.
    cornerPoints = iePointSelect(obj, ...
        'Select (1) lower left, (2) lower right, (3) upper right, (4) upper left', ...
        nPoints);
end

% We make sure that the rects are cleared because we are selecting new
% corner points here.  But not all the objects have these rects, and the
% code is inconsistent.  That needs fixing (BW)!
switch lower(obj.type)
    case 'scene'
        if wholeChart
            sz = sceneGet(obj,'size');
            x = sz(2); y = sz(1);
            cornerPoints = [1,y; x,y; x,1; 1,1];
        end
        obj = sceneSet(obj,'chart corner points',cornerPoints);
        
    case 'opticalimage'
        if wholeChart
            sz = oiGet(obj,'size');
            x = sz(2); y = sz(1);
            cornerPoints = [1,y; x,y; x,1; 1,1];
        end
        obj = oiSet(obj,'chart corner points',cornerPoints);
        
    case {'isa','sensor'}
        % Should set the corner points in this case, too!
        % And clear mccRectHandles, which should become chartRectHandles
        if wholeChart
            sz = sensorGet(obj,'size');
            x = sz(2); y = sz(1);
            cornerPoints = [1,y; x,y; x,1; 1,1];
        end
        % obj = sensorSet(obj,'mccRectHandles',[]);
        obj = sensorSet(obj,'chart corner points',cornerPoints);
        
    case 'vcimage'
        % Should set the corner points in this case, too!
        % And clear mccRectHandles, which should become chartRectHandles
        if wholeChart
            sz = ipGet(obj,'size');
            x = sz(2); y = sz(1);
            cornerPoints = [1,y; x,y; x,1; 1,1];
        end
        % obj = ipSet(obj,'mccRectHandles',[]);
        obj = ipSet(obj,'cornerpoints',cornerPoints);
        
    otherwise
        error('Unknown object type %s\n',obj.type);
end

if nargout == 3
    % Corner Points are lower left, lower right, upper right, upper left
    % Upper left is (x,y)
    % How far to the right is width
    % How far down is height
    x = cornerPoints(4,1);
    y = cornerPoints(4,2);
    width = cornerPoints(3,1) - cornerPoints(4,1);
    height = cornerPoints(1,2) - cornerPoints(4,2);
    rect = [x, y, width, height];
end

end



