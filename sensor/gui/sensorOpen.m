function sensorOpen(hObject,eventdata,handles)
% Initialize sensorImageWindow 
% 
%    sensorOpen(hObject,eventdata,handles)
%
% Copyright ImagEval Consultants, LLC, 2005.

% Choose default command line output for sensorImageWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

figure(hObject); 

vcSetFigureHandles('ISA',hObject,eventdata,handles);

val = vcGetSelectedObject('ISA');
if isempty(val)
    sensor = sensorCreate('default');
    vcReplaceAndSelectObject(sensor,1);
end

ieFontInit(hObject);

end