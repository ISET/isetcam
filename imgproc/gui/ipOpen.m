function ipOpen(hObject,eventdata,handles)
% Initialize ipWindow
% 
%   ipOpen(hObject,eventdata,handles)
%
% Copyright ImagEval Consultants, LLC, 2014.

% Choose default command line output for vcimageWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

vcSetFigureHandles('VCIMAGE',hObject,eventdata,handles);
figure(hObject); 

val = vcGetSelectedObject('VCIMAGE');
if isempty(val)
    ip = ipCreate('default');
    vcReplaceAndSelectObject(ip,1);
end

% Add the custom algorithms from the vcSESSION.CUSTOM to the popup lists.
ieFontInit(hObject);

end