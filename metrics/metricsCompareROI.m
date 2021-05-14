function [dEab,roiLocs] = metricsCompareROI(handles)
%
%  [dEab,roiLocs] = metricsCompareROI(handles)
%
%Author: ImagEval
%Purpose:
%   Compare the delta Eab values in a regioin of interest chosen from the
%   upper left hand image in the metrics window.
%
% Examples:
%   handles = guidata(metricsWindow);
%   [dEab,roiLocs] = metricsCompareROI(handles);
%

% handles = guidata(metricsWindow)
if ieNotDefined('handles'), error('metricsWindow handles required.'); end

[vci1, vci2] = metricsGetVciPair(handles);

roiLocs = metricsROI(handles,'img1');

dataXYZ1 = ipGet(vci1,'roixyz',roiLocs);
whitePnt{1} = ipGet(vci1,'whitepoint');

dataXYZ2 = ipGet(vci2,'roixyz',roiLocs);
whitePnt{2} = ipGet(vci2,'whitepoint');

dEab = deltaEab(dataXYZ1,dataXYZ2,whitePnt);

return;



