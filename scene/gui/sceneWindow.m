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
%  The sceneWindow_Apps all show any of the scenes stored in the
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

sceneW = ieSessionGet('scene window');

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
    else
        % No need to do anything. There is a window app and there are
        % scenes in the database.  We refresh below, but maybe we should do
        % it here?
    end
end

%% See if there is a live window.

if isempty(sceneW)
    % There is no existing scene window.  So we create one and store it in
    % the database. 
    sceneW = sceneWindow_App;
    ieSessionSet('scene window',sceneW);
end

% Maybe this should be sceneW.refresh?
sceneW.refresh;

end
