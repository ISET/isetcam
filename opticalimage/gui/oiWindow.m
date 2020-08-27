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
%   oi:  The scene you want in the window.  If empty, the currently
%           selected scene in global vcSESSION is used.  If there is no
%           selected scene a default scene is created and used.
%
% Outputs
%   oiW:  An sceneWindow_App object.
%
% Description
%
%  If there is a oiWindow_App stored in the vcSESSION database, this
%  interface opens that app.
%
%  If that slot is empty, this function creates one and stores it in the
%  database.
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

oiW = ieSessionGet('oi window');

if exist('oi','var')
    % A scene was passed in.  We add it to the database and select it.
    % That scene will appear in the window.
    ieAddObject(oi);
else
    % Get the currently selected scene
    oi = ieGetObject('oi');
    if isempty(oi)
        % There are no scenes. We create the default scene and add it to
        % the database
        oi = oiCreate;
        ieAddObject(oi);
    else
        % No need to do anything. There is a window app and there are
        % scenes in the database.  We refresh below, but maybe we should do
        % it here?
    end
end

%% See if there is a live window.

if isempty(oiW)
    % There is no existing scene window.  So we create one and store it in
    % the database as part of the opening function.
    oiW = oiWindow_App;
else
    try
        oiW.refresh;
    catch
        oiW = oiWindow_App;
        ieSessionSet('oi window',oiW);
    end
end


end
