function cornerPoints = chartCornerpoints(obj)
% Return a the outer corner points of a chart from sensor or ip window
%
%    cornerPoints = chartCornerpoints(obj)
%
% Have the user select the four corner points we need to define the
% positions of the chart patches.  
%
% The order is always lower left, lower right, upper right and upper left.
% This ordering arises from MCC work.  Maybe it should be upper left and
% then clockwise by option, some day.
%
% Example:
%    ieInit;
%    scene = sceneCreate;  camera = cameraCreate('default');
%    camera = cameraCompute(camera,scene);
%    cameraWindow(camera,'ip'); ip = cameraGet(camera,'ip');
%
%    cp = chartCornerpoints(ip);
%    ip = ipSet(ip,'mcc corner points',cp);
%    macbethDrawRects(ip,'on');
%    macbethDrawRects(ip,'off');
%
%    cameraWindow(camera,'sensor'); sensor = cameraGet(camera,'sensor');
%    cp = macbethCornerpoints(sensor);
%    sensor = sensorSet(sensor,'mcc corner points',cp);
%    macbethDrawRects(sensor,'on');
%    macbethDrawRects(sensor,'off');
%
% See also:  macbethSelect, macbethDrawRects, macbethRectangles
%
% Copyright Imageval LLC, 2014

if ieNotDefined('obj'), error('Sensor or IP object required.'); end

% obj is either a vcimage or a sensor image.  We make sure that the rects
% are cleared because we are selecting new corner points here.
switch lower(obj.type)
    case 'vcimage'
        obj = ipSet(obj,'mccRectHandles',[]);
        vcReplaceObject(obj);
        ipWindow
    
    case {'isa','sensor'}
        obj = sensorSet(obj,'mccRectHandles',[]);
        vcReplaceObject(obj);
        sensorImageWindow;
        
    otherwise
        error('Unknown object type');
end

% If the user didn't send in any corner points, and there aren't in the
% structure, go get them from the user in the window.
cornerPoints = vcPointSelect(obj,4,...
    'Select (1) lower left, (2) lower right, (3) upper right, (4) upper left');

end
