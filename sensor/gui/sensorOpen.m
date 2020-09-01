function sensorOpen(app)
% Deprecated
%
% Initialize sensorImageWindow 
% 
%    sensorOpen(hObject,eventdata,handles)
%
% Copyright ImagEval Consultants, LLC, 2005.

% Choose default command line output for sensorImageWindow

vcSetFigureHandles('ISA',hObject,eventdata,handles);

val = vcGetSelectedObject('ISA');
if isempty(val)
    sensor = sensorCreate('default');
    vcReplaceAndSelectObject(sensor,1);
end

ieFontInit(hObject);

end