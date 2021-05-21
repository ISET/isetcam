function plotMetrics(handles,plotType)
% Gateway routine to plot summary values from a metrics image.
%
%    plotMetrics(handles,plotType)
%
% At present only delta EAb is implemented.
%
%
% Example:
%  plotMetrics(handles,'dEab')
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('handles'); handles = metricsWindow; end
if ieNotDefined('plotType')
    contents = get(handles.popMetric,'String');
    plotType = contents{get(handles.popMetric,'Value')};
end

% Read in the two file names for the title
fname1 = metricsGet(handles,'image1name');
fname2 = metricsGet(handles,'image2name');

metricAxis = metricsGet(handles,'metricAxes');
axes(metricAxis);

% Have the user choose the ROI
set(handles.txtMessage,'Fontsize',6);
set(handles.txtMessage,'Fontweight','bold');
set(handles.txtMessage,'String','Select region in metrics image');
roiLocs = vcROISelect([],metricAxis);

% Well, this is kind of funky and needs to be fixed.
metricData = metricsGet(handles,'metricData');
data = vcImageGetROI(metricData,roiLocs);
set(handles.txtMessage,'String','');

figNum =  vcSelectFigure('GRAPHWIN');
plotSetUpWindow(figNum);

nBins = max(10,length(data(:))/10);
histogram(data(:),nBins);

xlabel(plotType); ylabel('Count');
title(sprintf('ROI: %s and %s ',fname1,fname2));
txt = sprintf('Mean   %.02f\nMedian %.02f\nSD     %.02f\nMin    %.02f\nMax   %.02f',...
    mean(data(:)),median(data(:)),std(data(:)),min(data(:)),max(data(:)));
plotTextString(txt,'ur');
grid on

return;
