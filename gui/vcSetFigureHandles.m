function vcSetFigureHandles(figType,app)
% Set figure handle information at opening window
%
%  vcSetFigureHandles(figType,hObject,eventdata,handles);
%
% Purpose:
%    Maintain the handles and main figure object representation
%
%  vcSetFigureHandles('ISA',hObject,eventdata,handles);
%
%  Shortly, this routine will go away and be replaced by ieSessionSet
%  entirely.
%
% Copyright ImagEval Consultants, LLC, 2005.

switch lower(figType)
    case 'main'
        ieSessionSet('mainwindow',hObject,eventdata,handles);
                
    case 'scene'
        ieSessionSet('scenewindow',app);
        
    case {'oi','opticalimage'}
        ieSessionSet('oiwindow',hObject,eventdata,handles);
        
    case {'isa','sensor'}
        ieSessionSet('sensorwindow',hObject,eventdata,handles);
        
    case {'vcimage'}
        ieSessionSet('vcimagewindow',hObject,eventdata,handles);
        
    case {'metrics'}
        ieSessionSet('metricswindow',hObject,eventdata,handles);
        
    otherwise
        error('Unknown figure type');
end


end
