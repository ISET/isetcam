function sensorW = sensorWindow(sensor)
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

if exist('sensor','var')
    % A sensor was passed in.  We add it to the database and select it.
    % That sensor will appear in the window.
    ieAddObject(sensor);
else
    % Get the currently selected scene
    sensor = ieGetObject('sensor');
    if isempty(sensor)
        % There are no sensors. We create the default sensor and add it to
        % the database
        sensor = sensorCreate;
        ieAddObject(sensor);
    end
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

end
