function sceneOpen(app)
% Deprecated
%   Moved into sceneWindow_App
% 
% Synopsis
%    sceneOpen(app)
%
% Inputs
%  app:   sceneWindow_App
%
% Outputs
%  N/A
%
% See also
%   sceneWindow_App

error('Moved')

end

%{
% Store the app iin the database for when we need it.
if isempty(ieSessionGet('scene window'))
    disp('Storing this sceneWindow_App in database');
    ieSessionSet('scene window',app);
else
    disp('sceneWindow_App exists in database. This as an extra window');
end

%  Check the preferences for ISET and adjust the font size.
ieFontInit(app);

end
%}