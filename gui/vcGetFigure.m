function app = vcGetFigure(obj)
% Return the figure number associated with an object. 
%
% Syntax
%   app = vcGetFigure(obj)
%
% Description
%   Get the app object to one of the ISETCam windows. Possible ISET objects
%   are scene, oi, sensor, ip.
%
%   This routine allows us to get the figure number when the object type is
%   not identified in the main routine, such as getting an ROI for an oi,
%   scene, sensor or other type of window.
%
%   There is a separate routine for GraphWins.  But I am not sure why.
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also
%   vcEquivalentObjtype, vcGetObjectType
   
% Examples:
%{
 scene = sceneCreate; 
 sceneWindow(scene);
 app = vcGetFigure(scene)
%}

%%
objType = vcGetObjectType(obj);

% Forces the objType string to one of original names below.
objType = vcEquivalentObjtype(objType);

% hdl = [];
switch lower(objType)
    case 'scene'
        app = ieSessionGet('scenewindow');
    case {'opticalimage'}
        app = ieSessionGet('oiwindow');
    case {'isa'}
        app = ieSessionGet('sensorwindow');
    case {'vcimage'}
        app = ieSessionGet('ipwindow');
        
    otherwise
        error('Unknown object type.');
end

end