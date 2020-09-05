function oiW = oiWindow(oi)
% Wrapper that replaces the GUIDE oiWindow functionality
%
% Synopsis
%   oiW = oiWindow(oi)
%
% Brief description
%   Opens a oiWindow interface based on the oiWindow_App. 
%
% Inputs
%   oi:     The oi you want in the window.  If empty, the currently
%           selected oi in global vcSESSION is used.  If there is no
%           selected oi a default scene is created and used.
%
% Outputs
%   oiW:  An oiWindow_App object.
%
% Description
%
%  If there is a oiWindow_App stored in the vcSESSION database, this
%  interface opens that app.
%
%  If that slot is empty, this function creates one and stores it in the
%  database.
%
%  Sometimes there is a stale handle to an app in the vcSESSION database.
%  This code tries the non-empty (but potentially stale) app.  If it works,
%  onward. If not, then it creates a new one, stores it, and uses it.
%
%  The oiWindow_App all show any of the ois stored in the vcSESSION.OI
%  database slot.
%
% See also
%    oiWindow_App
%

% Examples
%{
   oiWindow;
%}
%{
   scene = sceneCreate;
   oi = oiCreate;  oi = oiCompute(oi,scene);
   oiWindow(oi);
%}

%% Add the scene to the database if it is in the call

if exist('oi','var')
    % An oi was passed in.  We add it to the database and select it.
    % That oi will appear in the window.
    ieAddObject(oi);
else
    % Get the currently selected scene
    oi = ieGetObject('oi');
    if isempty(oi)
        % There are no ois. We create the default oi and add it to
        % the database
        oi = oiCreate;
        ieAddObject(oi);
    end
end

%% See if there is a live window.

oiW = ieSessionGet('oi window');

if isempty(oiW)
    % Empty, so create one and put it in the vcSESSION
    oiW = oiWindow_App;
    ieSessionSet('scene window',oiW);
elseif ~isvalid(oiW)
    % Replace the invalid one
    oiW = oiWindow_App;
    ieSessionSet('scene window',oiW);
else
    % Just refresh it
    oiW.refresh;
end

end
