function roiLocs = metricsROI(hndl, whichImage)
%
%   roiLocs = metricsROI(hndl,whichImage)
%
%Author: ImagEval
%Purpose:
%    Pick out an ROI from one of the 3 windows in the metrics window.
%    These are img1,img2, and metricImage.
%
% Examples:
%    hndl = guidata(metricsWindow);
%    roiLocs = metricsROI(hndl,'img1');
%    roiLocs = metricsROI(hndl,'img2');
%    h = metricsWindow; roiLocs = metricsROI(h,'metricImage');

if ieNotDefined('hndl'), error('metricsWindow handle required.'); end
if ieNotDefined('whichImage'), error('Must specify which metrics image.'); end

roiLocs = [];

switch lower(whichImage)
    case {'img1', 'image1', 'upperleftimage'}
        if isempty(hndl.img1), errordlg('No image 1 data');
        else rect = round(getrect(hndl.img1));
        end
    case {'img2', 'image2', 'upperrightimage'}
        if isempty(hndl.img2), errordlg('No image 2 data')
        else rect = round(getrect(hndl.img2));
        end
    case {'metricimage', 'lowerimage', 'metricImg'}
        if isempty(hndl.imgMetric), errordlg('No data in metric image');
        else rect = round(getrect(hndl.imgMetric));
        end
    otherwise
        error('Unknown metric image handle.');
end

if isempty(rect), return;
else
    cmin = rect(1);
    cmax = rect(1) + rect(3);
    rmin = rect(2);
    rmax = rect(2) + rect(4);

    [c, r] = meshgrid(cmin:cmax, rmin:rmax);
    roiLocs = [r(:), c(:)];
end

return;