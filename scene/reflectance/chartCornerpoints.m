function cornerPoints = chartCornerpoints(obj)
% Return the outer corner points of a chart from sensor or ip window
%
% Syntax:
%    cornerPoints = chartCornerpoints(obj)
%
% Description:
%  The user selects the four corner points we need to define the positions
%  of the chart patches.  Graphical selection in the ip or sensor window.
%
%  The order is always lower left, lower right, upper right and upper left.
%  This ordering arises from MCC work.  Maybe it should be upper left and
%  then clockwise by option, some day.
%
% Inputs
%   obj:   Senor or ip struct
%
% Outputs
%   cornerPoints:  Matrix (4x2) in (col,row), i.e. (x,y) format.
%
% Copyright Imageval LLC, 2014
%
% See also:  
%   macbethSelect, macbethDrawRects, macbethRectangles

% Examples:
%{    
  ieInit;
  scene = sceneCreate;  camera = cameraCreate('default');
  camera = cameraCompute(camera,scene);
  cameraWindow(camera,'ip'); ip = cameraGet(camera,'ip');

  cp = chartCornerpoints(ip);
  ip = ipSet(ip,'mcc corner points',cp);
  macbethDrawRects(ip,'on');
  macbethDrawRects(ip,'off');

  cameraWindow(camera,'sensor'); sensor = cameraGet(camera,'sensor');
  cp = macbethCornerpoints(sensor);
  sensor = sensorSet(sensor,'mcc corner points',cp);
  macbethDrawRects(sensor,'on');
  macbethDrawRects(sensor,'off');
%}

%% TODO
%  The chart markings and rects should be updated to use the chartXXX
%  routines, without the specialization for MCC.  This will require some
%  fixing of the sceneSet,oiSet, ... and so forth. 

if ieNotDefined('obj'), error('Sensor or IP object required.'); end

% Get the user to select corner points in the window.
cornerPoints = vcPointSelect(obj,4,...
    'Select (1) lower left, (2) lower right, (3) upper right, (4) upper left');

% We make sure that the rects are cleared because we are selecting new
% corner points here.  But not all the objects have these rects, and the
% code is inconsistent.  That needs fixing (BW)!
switch lower(obj.type)
    case 'scene'
        obj = sceneSet(obj,'chart corners',cornerPoints);
        vcReplaceObject(obj);
        sceneWindow;
        
    case 'opticalimage'
        obj = oiSet(obj,'chart corners',cornerPoints);
        vcReplaceObject(obj);
        oiWindow;
        
    case {'isa','sensor'}
        % Should set the corner points in this case, too!
        % And clear mccRectHandles, which should become chartRectHandles
        obj = sensorSet(obj,'mccRectHandles',[]);
        obj = sensorSet(obj,'cornerpoints',cornerPoints);
        vcReplaceObject(obj);
        sensorImageWindow;
        
    case 'vcimage'
        % Should set the corner points in this case, too!
        % And clear mccRectHandles, which should become chartRectHandles
        obj = ipSet(obj,'mccRectHandles',[]);
        obj = ipSet(obj,'cornerpoints',cornerPoints);
        vcReplaceObject(obj);
        ipWindow
        
    otherwise
        error('Unknown object type');
end


end
