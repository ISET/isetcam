function [fullName, metricName] = metricsSaveData(figNum)
%
%   [fullName,metricName] = metricsSaveData(figNum)
%
% Author: ImagEval
% Purpose:
%   Save the userdata field of the metrics window to Matlab
%   file.  The userdata field contains the currently computed metrics
%   image. Various auxiliary state information about the window is saved as
%   well.
%
%   To save the userdata as a TIFF image for presentations, use
%   metricsSaveImage.
%

if ieNotDefined('figNum'), error('figNum required.'); end

data = get(figNum, 'userdata');
if isempty(data)
    warning('No metric data present in userdata field.');
    return;
end

% Retrieve information about the fields
handles = guihandles(figNum);

% Have the user select a file name.  Make sure the extension is mat.
fullName = vcSelectDataFile('session', 'w');
[p, n, e] = fileparts(fullName);
fullName = [p, filesep, n, '.mat'];

% Read the current metric.  Based on this metric, adjust the data.
contents = get(handles.popMetric, 'String');
metricName = contents(get(handles.popMetric, 'Value'));
metricName = char(metricName);

% Read the current metric.  Based on this metric, adjust the data.
contents = get(handles.popImageList1, 'String');
image1 = contents(get(handles.popImageList1, 'Value'));

% Read the current metric.  Based on this metric, adjust the data.
contents = get(handles.popImageList2, 'String');
image2 = contents(get(handles.popImageList2, 'Value'));

save(fullName, 'data', 'metricName', 'image1', 'image2');

return;