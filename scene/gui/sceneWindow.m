function sceneW = sceneWindow(scene)
% Wrapper that replaces the GUIDE sceneWindow functionality
%
% Synopsis
%   sceneW = sceneWindow(scene)
%
% Brief description
%   Opens a sceneWindow interface based on the sceneWindow_App. 
%
% Inputs
%   scene:  The scene you want in the window.  If empty, the currently
%           selected scene in global vcSESSION is used.  If there is no
%           selected scene a default scene is created and used.
%
% Outputs
%   sceneW:  An sceneWindow_App object.
%
% Description
%
%  If there is a sceneWindow_App stored in the vcSESSION database, this
%  interface opens that app.
%
%  If that slot is empty, this function creates one and stores it in the
%  database.
%
%  Sometimes there is a stale handle to an app in the vcSESSION database.
%  This code tries the non-empty (but potentially stale) app.  If it works,
%  onward. If not, then it creates a new one, stores it, and uses it.
%
%  The sceneWindow_App shows any of the scenes stored in the
%  vcSESSION.SCENE database slot.
%
% See also
%    sceneWindow_App
%

% Examples
%{
   sceneWindow;
%}
%{
   scene = sceneCreate;
   sceneWindow(scene);
%}

%% Add the scene to the database if it is in the call

if exist('scene','var')
    % A scene was passed in.  We add it to the database and select it.
    % That scene will appear in the window.
    ieAddObject(scene);
else
    % Get the currently selected scene
    scene = ieGetObject('scene');
    if isempty(scene)
        % There are no scenes. We create the default scene and add it to
        % the database
        scene = sceneCreate;
        ieAddObject(scene);
    end
end

%% See if there is a live window.

sceneW = ieSessionGet('scene window');

if isempty(sceneW)
    % Empty, so create one and put it in the vcSESSION
    sceneW = sceneWindow_App;
    ieSessionSet('scene window',sceneW);
elseif ~isvalid(sceneW)
    % Replace the invalid one
    sceneW = sceneWindow_App;
    ieSessionSet('scene window',sceneW);
else
    % Just refresh it
    sceneW.refresh;
end

end
