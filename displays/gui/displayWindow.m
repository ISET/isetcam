function displayW = displayWindow(thisD)
% Wrapper that replaces the GUIDE sceneWindow functionality
%
% Synopsis
%   displayW = displayWindow(thisD)
%
% Brief description
%   Opens a displayWindow interface based on the displayWindow_App.
%
% Inputs
%   thisD:  The display you want in the window.  If empty, the currently
%           selected display in global vcSESSION is used.  If there is no
%           selected display a default scene is created and used.
%
% Outputs
%   displayW:  An displayWindow_App object.
%
% Description
%
%  If there is a displayWindow_App stored in the vcSESSION database, this
%  interface opens that app.
%
%  If that slot is empty, this function creates one and stores it in the
%  database.
%
%  Sometimes there is a stale handle to an app in the vcSESSION database.
%  This code tries the non-empty (but potentially stale) app.  If it works,
%  onward. If not, then it creates a new one, stores it, and uses it.
%
%  The displayWindow_App shows any of the scenes stored in the
%  vcSESSION.SCENE database slot.
%
% See also
%    sceneWindow_App
%

% Examples
%{
   displayWindow;
%}
%{
   d = displayCreate;
   displayWindow(d);
%}

%% Add the scene to the database if it is in the call

if exist('thisD','var')
    % A scene was passed in.  We add it to the database and select it.
    % That scene will appear in the window.
    ieAddObject(thisD);
else
    % Get the currently selected scene
    thisD = ieGetObject('display');
    if isempty(thisD)
        % There are no scenes. We create the default scene and add it to
        % the database
        thisD = displayCreate;
        ieAddObject(thisD);
    end
end

%% See if there is a live window.

displayW = ieSessionGet('display window');

if isempty(displayW)
    % Empty, so create one and put it in the vcSESSION
    displayW = displayWindow_App;
    ieSessionSet('display window',displayW);
elseif ~isvalid(displayW)
    % Replace the invalid one
    displayW = displayWindow_App;
    ieSessionSet('display window',displayW);
else
    % Just refresh it
    displayW.refresh;
end

end
