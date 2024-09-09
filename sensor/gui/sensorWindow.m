function sensorW = sensorWindow(sensor,varargin)
% Wrapper that replaces the GUIDE oiWindow functionality
%
% Synopsis
%   sensorW = sensorWindow(sensor)
%
% Brief description
%   Opens a sensorWindow interface based on the sensorWindow_App.
%
% Inputs
%   sensor: The sensor you want in the window.  If empty, the currently
%           selected sensor in global vcSESSION is used.  If there is no
%           selected sensor a default sensor is created and used.
%
% Key/val options
%   show:   Executes a drawnow command on exiting.
%           (Optional, default true)
%   replace: Logical.  If true, then replace the current sensor, rather than
%            adding the sensor to the database.  Default: false
%   gamma:    Display gamma, typically [0-1]     
%
% Outputs
%   sensorW:  An sensorWindow_App object.
%
% Description
%
%  If there is a sensorWindow_App stored in the vcSESSION database, this
%  interface opens that app.
%
%  If that slot is empty, this function creates one and stores it in the
%  database.
%
%  Sometimes there is a stale handle to an app in the vcSESSION database.
%  This code tries the non-empty (but potentially stale) app.  If it works,
%  onward. If not, then it creates a new one, stores it, and uses it.
%
%  The sensorWindow_App all show any of the sensors stored in the
%  vcSESSION.ISA database slot.  (ISA is image sensor array).
%
% See also
%    sceneWindow_App, oiWindow_App
%

% Examples
%{
   sensorWindow;
%}
%{
   scene = sceneCreate;
   oi = oiCreate;  oi = oiCompute(oi,scene);
   oiWindow(oi);
%}

%% Add a sensor to the database if it is in the call

varargin = ieParamFormat(varargin);

if ~exist('sensor','var') || isempty(sensor)
    % Get the currently selected scene
    sensor = ieGetObject('sensor');
    if isempty(sensor)
        % There are no ois. We create the default oi and add it to
        % the database
        sensor = sensorCreate;
        ieAddObject(sensor);
    else
        % There is a sensor in vcSESSION. None was passed in.  So this is a
        % refresh only.
        try
            app = ieAppGet(sensor);
        catch
            app = sensorWindow_App;
        end
        sensorW = app;
        app.refresh;
        return;
    end

end

p = inputParser;
p.addRequired('oi',@(x)(isstruct(x) && isequal(x.type,'sensor')));
p.addParameter('show',true,@islogical);
p.addParameter('replace',false,@islogical);
p.addParameter('gamma',[],@isscalar);

p.parse(sensor,varargin{:});

%% A sensor exists

% We add it to the database and select it.
% That sensor will appear in the sensorWindow.
if p.Results.replace, ieReplaceObject(sensor);
else,                 ieAddObject(sensor);
end

%% See if there is a window.

sensorW = ieSessionGet('sensor window');

if isempty(sensorW)
    % Empty, so create one and put it in the vcSESSION
    sensorW = sensorWindow_App;
    ieSessionSet('sensor window',sensorW);
elseif ~isvalid(sensorW)
    % Replace the invalid one
    sensorW = sensorWindow_App;
    ieSessionSet('sensor window',sensorW);
else
    % Just refresh it
    sensorW.refresh;
end

%%

if ~isempty(p.Results.gamma)
    sensor = sensorSet(sensor,'gamma',p.Results.gamma);
    ieReplaceObject(sensor);
end

% Assume true if it does not exist.  Or if it is true.
if p.Results.show, drawnow; end

end
