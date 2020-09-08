function cornerPoints = chartCornerpoints(obj,wholeChart)
% Return the outer corner points of a chart from sensor or ip window
%
% Syntax:
%    cornerPoints = chartCornerpoints(obj,wholeChart)
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
%
% Copyright Imageval LLC, 2014
%
% See also:  
%   chartROI, chartRectangles, chartRectsDraw


% Examples:
%{    
  scene = sceneCreate;  camera = cameraCreate('default');
  camera = cameraCompute(camera,scene);
  cameraWindow(camera,'ip'); ip = cameraGet(camera,'ip');

  cp = chartCornerpoints(ip,true);
  sFactor = 0.3;
  [rects, mLocs, pSize] = chartRectangles(cp, 4,6, sFactor);
  
  % Plot the rects
  rectHandles = chartRectsDraw(ip,rects);
  % delete(rectHandles);
%}

%% TODO
%  The chart markings and rects should be updated to use the chartXXX
%  routines, without the specialization for MCC.  This will require some
%  fixing of the sceneSet,oiSet, ... and so forth. 

if ieNotDefined('obj'), error('Scene,oi,sensor or ip object required.'); end
if ieNotDefined('wholeChart'), wholeChart = false; end

% Make sure this is the selected object.  Perhaps we should test rather
% than over-write.  But I am tired just now.
ieReplaceObject(obj);
ieRefreshWindow(obj.type);  % Make sure it is displayed.

if ~wholeChart
    nPoints = 4;
    % Get the user to select corner points in the window.
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
        obj = sceneSet(obj,'chart corners',cornerPoints);
        ieReplaceObject(obj);
        % sceneWindow;
        
    case 'opticalimage'
        if wholeChart
            sz = oiGet(obj,'size');
            x = sz(2); y = sz(1);
            cornerPoints = [1,y; x,y; x,1; 1,1];
        end
        obj = oiSet(obj,'chart corners',cornerPoints);
        ieReplaceObject(obj);
        % oiWindow;
        
    case {'isa','sensor'}
        % Should set the corner points in this case, too!
        % And clear mccRectHandles, which should become chartRectHandles
        if wholeChart
            sz = sensorGet(obj,'size');
            x = sz(2); y = sz(1);
            cornerPoints = [1,y; x,y; x,1; 1,1];
        end
        % obj = sensorSet(obj,'mccRectHandles',[]);
        obj = sensorSet(obj,'cornerpoints',cornerPoints);
        ieReplaceObject(obj);
        % sensorWindow;
        
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
        ieReplaceObject(obj);
        % ipWindow
        
    otherwise
        error('Unknown object type %s\n',obj.type);
end


end
