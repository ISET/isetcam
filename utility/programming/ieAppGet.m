function [app, appAxis] = ieAppGet(obj,varargin)
% Return the app and main axis associated with an object.
%
% TODO:  Maybe eliminate 'select' option
%
% Syntax
%   [app, appAxis] = ieAppGet(obj,varargin)
%
% Input
%   obj:    One of the ISETCam main object types, scene, oi, sensor, ip.
%           Or a of one of the main types, in which case we use
%           ieGetObject(str)
%           Or an app from a valid appdesigner
%           Or a Matlab figure
%
% Optional key/value
%   select: If true, put the focus on the figure (call figure(app.figure1))
%           Perhaps we should call app.refresh?
%
% Output
%   app:      The window app, or empty if there is no app and obj
%             a Matlab figure
%   appAxis:  The axes of the main app window or the axes of the
%             Figure.
%
% Description
%   Primary use is to get the app object and main image axes
%   corresponding to one of the ISETCam windows. Possible ISET objects
%   are scene, oi, sensor, ip. obj can be one of these structs, or
%   just a string that identifies which of the struct to get using
%   ieGetObject. The main image axis can also be returned.
%
%   In some cases the obj may be a Matlab figure.  In that case, app
%   is returned empty and appAxis is the CurrentAxes of the figure.
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

%% Parse
p = inputParser;

validApp = {'coneRectWindow_App'};  % These designer apps are handled
p.addRequired('obj',@(x)(isstruct(x) || ...
    ischar(x) || ...
    ismember(class(x),validApp) || ...
    isa(x,'matlab.ui.Figure')));
p.addParameter('select',true,@islogical);
p.parse(obj,varargin{:});
select = p.Results.select;

if ischar(obj)
    objType = vcEquivalentObjtype(obj);
elseif isstruct(obj) && isfield(obj,'type')
    objType = vcEquivalentObjtype(obj.type);
end

%% Looks up the names of the app and the proper axis

if exist('objType','var')
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
        case {'display'}
            app = ieSessionGet('display window');
            if isempty(app), error('Undefined display app'); end
            appAxis = app.displayImage;
        otherwise
            error('Unknown object type.');
    end

    if select, figure(app.figure1); end

elseif isa(obj,'matlab.ui.Figure')
    app = [];
    appAxis = get(obj,'CurrentAxes');
    if select, figure(obj); end
else
    % Either an app or a Matlab figure
    app = obj;
    switch class(app)
        case 'coneRectWindow_App'
            appAxis = app.imgMain;
            if select, figure(app.coneMosaicWindow); end
        otherwise
            error('Unknown app %s',class(app));
    end
end
