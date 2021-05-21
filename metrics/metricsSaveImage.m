function [fullName,metricName] = metricsSaveImage(figNum)
%
%   [fullName,metricName] = metricsSaveImage(figNum)
%
% Author: ImagEval
% Purpose:
%   Save the metric image of the metrics window to an image file.  The
%   metricImage contains the currently computed metrics image. The image is
%   saved in a TIFF file format.
%
%   This routine adjusts the values so they fit in the TIFF scale. To save
%   the data without adjustment, use menuSaveData.  This writes the data
%   into a Matlab file along with auxiliary information.
%

if ieNotDefined('figNum'), error('figNum required.'); end

% Have the user select a file name.  Make the extension tiff.
fullName = vcSelectDataFile('session','w');
if isempty(fullName), return;
else
    [p,n,e] = fileparts(fullName);
    fullName = fullfile(p,[n,'.tiff']);
end

% Get the image data.  This should be scaled in some way that we haven't
% yet really worked through.
data = metricsGet(figNum,'metricImageData');
if isempty(data)
    errordlg(sprintf('No metric image data in figure %f\n',figNum));
    return;
else
    % Write out the data.
    imwrite(data,fullName,'tiff');
end

return;