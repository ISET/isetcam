function [app, appAxis] = vcGetFigure(obj,select)
% Return the app and main axis associated with an object.
%
% Syntax
%   [app, appAxis] = vcGetFigure(obj,[select])
%
% Input
%   obj:  One of the ISETCam main object types, scene, oi, sensor, ip
% select: If true, the select the figure also
%
% Output
%   app:      The window app
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
%   ieAxisGet, vcEquivalentObjtype, vcGetObjectType

% Examples:
%{
 scene = sceneCreate;
 sceneWindow(scene);
 [app,appAxis] = vcGetFigure(scene)
%}

%%
if ieNotDefined('obj'), error('An ISETCam obj required'); end
if ieNotDefined('select'), select = true; end

%% Forces the objType string to one of original names below.
objType = vcEquivalentObjtype(obj.type);

%% Looks up the names of the app and the proper axis

switch lower(objType)
    case 'scene'
        app = ieSessionGet('scene window');
        if isempty(app), error('Undefined scene app'); end
        appAxis = app.sceneImage;
    case {'opticalimage'}
        app = ieSessionGet('oi window');
        if isempty(app), error('Undefined oi app'); end
        appAxis = app.oiImage;
    case {'isa'}
        app = ieSessionGet('sensor window');
        if isempty(app), error('Undefined sensor app'); end
        appAxis = app.imgMain;
    case {'vcimage'}
        app = ieSessionGet('ip window');
        if isempty(app), error('Undefined ip app'); end
        appAxis = app.ipImage;
    otherwise
        error('Unknown object type.');
end

if select, figure(app.figure1); end
end
