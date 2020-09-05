function [app, appAxis] = vcGetFigure(obj)
% Return the figure number associated with an object. 
%
% Syntax
%   [app, appAxis] = vcGetFigure(obj)
%
% Input
%   obj:  One of the ISETCam main object types, scene, oi, sensor, ip
% 
% Output
%   app:  The window app
%   appAxis:  The axis of the main window;
%
% Description
%   Get the app object to one of the ISETCam windows. Possible ISET objects
%   are scene, oi, sensor, ip.
%
%   This routine allows us to get the figure number when the object type is
%   not identified in the main routine, such as getting an ROI for an oi,
%   scene, sensor or other type of window.
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
% objType = vcGetObjectType(obj);

% Forces the objType string to one of original names below.
objType = vcEquivalentObjtype(obj.type);

% hdl = [];
switch lower(objType)
    case 'scene'
        app = ieSessionGet('scene window');
        appAxis = app.sceneImage;
    case {'opticalimage'}
        app = ieSessionGet('oi window');
        appAxis = app.oiImage;
    case {'isa'}
        app = ieSessionGet('sensor window');
        appAxis = app.imgMain;
    case {'vcimage'}
        app = ieSessionGet('ip window');
        appAxis = [];  % Fill in when you know it

    otherwise
        error('Unknown object type.');
end

end