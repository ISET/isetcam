function ipW = ipWindow(ip)
% Wrapper that replaces the GUIDE oiWindow functionality
%
% Synopsis
%   ipW = ipWindow(ip)
%
% Brief description
%   Opens an ipWindow interface based on the ipWindow_App.
%
% Inputs
%   ip:  The image processor you want in the window.  If empty, the currently
%        selected ip in global vcSESSION is used.  If there is no
%        selected ip a default ip is created and used.
%   show:   Executes a drawnow command on exiting.
%           (Optional, default true)
%
% Outputs
%   ipW:  An ipWindow_App object.
%
% Description
%
%  If there is a ipWindow_App stored in the vcSESSION database, this
%  interface opens that app.
%
%  If that slot is empty, this function creates one and stores it in the
%  database.
%
%  Sometimes there is a stale handle to an app in the vcSESSION database.
%  This code tries the non-empty (but potentially stale) app.  If it works,
%  onward. If not, then it creates a new one, stores it, and uses it.
%
%  The ipWindow_App all show any of the ips stored in the vcSESSION.IP
%  database slot.
%
% See also
%    sceneWindow_App, oiWindow_App
%

% Examples
%{
   ipWindow;
%}
%{
   scene = sceneCreate;
   oi = oiCreate;  oi = oiCompute(oi,scene);
   oiWindow(oi);
%}

%% Add a sensor to the database if it is in the call

if exist('ip','var')
    % An image process was passed in.  We add it to the database and select it.
    % That ip will appear in the window.
    ieAddObject(ip);
else
    % Get the currently selected scene
    ip = ieGetObject('ip');
    if isempty(ip)
        % There are no ips. We create the default ip and add it to
        % the database
        ip = ipCreate;
        ieAddObject(ip);
    end
end

%% See if there is a window.

ipW = ieSessionGet('ip window');

if isempty(ipW)
    % Empty, so create one and put it in the vcSESSION
    ipW = ipWindow_App;
    ieSessionSet('ip window',ipW);
elseif ~isvalid(ipW)
    % Replace the invalid one
    ipW = ipWindow_App;
    ieSessionSet('ip window',ipW);
else
    % Just refresh it
    ipW.refresh;
end

% Assume true if it does not exist.  Or if it is true.
if ~exist('show','var') || show, drawnow; end

end
