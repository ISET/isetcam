function sceneOpen(app)
% Initialize sceneWindow
% 
%    sceneOpen(hObject,eventdata,handles)
%
% Copyright ImagEval Consultants, LLC, 2005.

% Choose default command line output for microLensWindow

% Store the app iin the database for when we need it.
vcSetFigureHandles('SCENE',app);

%  Check the preferences for ISET and adjust the font size.
ieFontInit(app);

end
