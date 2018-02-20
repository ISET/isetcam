function figNum = vcGetFigure(obj)
% Return the figure number associated with an object. 
%
%     figNum = vcGetFigure(obj)
%
%   Possible ISET objects are scene, opticalimage, isa, vcimage.  This
%   routine allows us to get the figure number when the object type is not
%   identified in the main routine, such as getting an ROI for an oi,
%   scene, sensor or other type of window.
%
%   There is a separate routine for GraphWins.  But I am not sure why.
%
% Examples:
%  figNum = vcGetFigure(obj)
%  figure(figNum);
%  handles = guihandle(figNum);
%
% Copyright ImagEval Consultants, LLC, 2005.

% global vcSESSION;

objType = vcGetObjectType(obj);
objType = vcEquivalentObjtype(objType);

hdl = [];
switch lower(objType)
    case 'scene'
        figNum = ieSessionGet('scenewindow');
    case {'opticalimage'}
        figNum = ieSessionGet('oiwindow');
    case {'isa'}
        figNum = ieSessionGet('sensorwindow');
    case {'vcimage'}
        figNum = ieSessionGet('ipwindow');
        
    otherwise
        error('Unknown object type.');
end

return;