function bool = mainOpen(hObject,eventdata,handles)
% Initialize sceneWindow and check for key.
%
%    bool = mainOpen(hObject,eventdata,handles)
%
% P-code.
%
% Copyright ImagEval Consultants, LLC, 2011.

bool = 0;
val = ieKeyVerify;
if ~strcmp(val{1},md5([num2str(date),'1951'])),
    errordlg('No key.  Please contact ImagEval');
    close(hObject);
    return;
else bool = 1;
end

% Choose default command line output for microLensWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%  Check the preferences for ISET and adjust the font size.
ieFontInit(hObject);

return;