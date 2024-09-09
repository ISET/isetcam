function sceneW = sceneWindow(scene,varargin)
% Wrapper that replaces the GUIDE sceneWindow functionality
%
% Synopsis
%   sceneW = sceneWindow(scene,varargin)
%
% Brief description
%   Opens a sceneWindow interface based on the sceneWindow_App.
%
% Inputs
%   scene:  The scene you want in the window.  If empty, the currently
%           selected scene in global vcSESSION is used.  If there is no
%           selected scene a default scene is created and used.
%           (Optional, default is currently selected scene)
%
% Optional key/val
%   show:   Executes a drawnow command on exiting.
%           (Optional, default true)
%   replace: Logical.  If true, then replace the current scene, rather than
%            adding the scene to the database.  Default: false
%   render flag:  'rgb','hdr','clip','monochrome'
%   gamma:    Display gamma, typically [0-1]
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
%  Or replace the current scene if the third argument is true
%
varargin = ieParamFormat(varargin);

if ~exist('scene','var') || isempty(scene)
    % Get the currently selected scene
    scene = ieGetObject('scene');
    if isempty(scene)
        % There are no scenes. We create the default scene and add it to
        % the database
        scene = sceneCreate;
        ieAddObject(scene);
    else
        % There is a scene in vcSESSION. None was passed in.  So this is a
        % refresh only.
        try
            app = ieAppGet(scene);
        catch
            app = sceneWindow_App;
        end
        sceneW = app;
        app.refresh;
        return;
    end

end

p = inputParser;
p.addRequired('scene',@(x)(isstruct(x) && isequal(x.type,'scene')));
p.addParameter('show',true,@islogical);
p.addParameter('replace',false,@islogical);
p.addParameter('renderflag',[],@ischar);
p.addParameter('gamma',[],@isscalar);

p.parse(scene,varargin{:});

%% Manage the scene parameters

% We add it to the database and select it.
% That oi will appear in the oiWindow.
if p.Results.replace, ieReplaceObject(scene);
else,                 ieAddObject(scene);
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

%% Adjust

% Someday, we may have renderflag and gamma slots in the oi itself.
% So I replace them now after setting, to future-proof.
if ~isempty(p.Results.renderflag)
    scene = sceneSet(scene,'render flag',p.Results.renderflag);
    ieReplaceObject(scene);
end

if ~isempty(p.Results.gamma)
    scene = sceneSet(scene,'gamma',p.Results.gamma);
    ieReplaceObject(scene);
end

% Assume true if it does not exist.  Or if it is true.
if p.Results.show, drawnow; end

end
