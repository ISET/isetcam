function [app, appAxis] = ieAppGet(obj,select)
% Return the app and main axis associated with an object.
%
% Syntax
%   [app, appAxis] = ieAppGet(obj,[select])
%
% Input
%   obj:    One of the ISETCam main object types, scene, oi, sensor, ip
%   select: If true, put the focus on the figure (call figure(app.figure1))
%           Perhaps we should call app.refresh?
%
% Output
%   app:      The window app
%   appAxis:  The axis of the main window;
%
% Description
%   Get the app object to one of the ISETCam windows. Possible ISET objects
%   are scene, oi, sensor, ip.   The main image axis can also be returned.
%
%   If select is 'true' then the focus is placed on the figure.
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also
%   ieAxisGet, vcEquivalentObjtype, vcGetObjectType

% Examples:
%{
 scene = sceneCreate;
 sceneWindow(scene);
 [app,appAxis] = ieAppGet(scene)
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
