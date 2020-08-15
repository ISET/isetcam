function thisWindow = sceneWindow2(scene)
% Testing idea for how to replace the old sceneWindow function
%
% We do not want to re-write all the all sceneWindow(scene) calls.
%
%
% See also
%

% Examples
%{
   sceneWindow2;
%}
%{
   scene = sceneCreate;
   sceneWindow2(scene);
%}
%{
   scene = sceneCreate('slanted bar');
   thisWindow = sceneWindow2(scene);
%}

%% Add the scene to the database if it is in the call

if exist('scene','var')
    ieAddObject(scene); 
else
    ieAddObject(sceneCreate);
end

%% See if there is a live window.
thisWindow = ieSessionGet('scene window');

try
    % This should bring it up.  We probably need to refresh, though
    figure(thisWindow.figure1);
catch
    % This should just see it.
    thisWindow = sceneWindow_App;
end

thisWindow.refresh;

end
