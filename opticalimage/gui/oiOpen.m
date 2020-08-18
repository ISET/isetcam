function bool = oiOpen(oiW)
% Deprecated: Function is now public in oiWindow_App
%
%
% Initialize oiWindow
% 
%    oiOpen(oiW)
%
% Copyright ImagEval Consultants, LLC, 2005.

% Choose default command line output for microLensWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

vcSetFigureHandles('OI',hObject,eventdata,handles);

%  Check the preferences for ISET and adjust the font size.
ieFontInit(hObject);

end