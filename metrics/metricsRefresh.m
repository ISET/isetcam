function metricsRefresh(handles)
% Refresh the metrics window. 
%
%   metricsRefresh(handles)
%
% This call resets the pull down options on the right, coordinating the
% contents of those pull downs with the available images in the current
% ImageProc window.
%
% Copyright ImagEval Consultants, LLC, 2005.

% Set the names in the popups on the right to the available vcimages.
names = vcGetObjectNames('VCIMAGE');
set(handles.popImageList1,'String',names);
set(handles.popImageList2,'String',names);

% Display the two vci images in the axes
handles = metricsShowImage(handles);

% Display the metric values in its axis
handles = metricsShowMetric(handles);

% Describe the image properties in the text boxes
metricsDescription(handles);

return;
