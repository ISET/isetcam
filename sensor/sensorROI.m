function roiLocs = sensorROI(sensor,roiType);
% Return roiLocs for a region of the sensor.
%
%  roiLocs = sensorROI(sensor,[roiType='center']);
%
% The routine makes it easy to pull out the center locations, or various
% corners
% 
%  roiType is one of 'center','upperLeft','upperRight', ...
%
%Example:
%    roiLocs = sensorROI;
%
%    sensor = vcGetObject('sensor');
%    roi = sensorROI(sensor,'center');
%    sensor = sensorSet(sensor,'roi',roi);
%    v = sensorGet(sensor,'roivolts');
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('roiType'), roiType = 'center'; end
if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end

switch lower(roiType)
    case 'center';
        sz = sensorGet(sensor,'size');
        rect(1) = sz(2)/4;
        rect(2) = sz(1)/4; 
        rect(3) = sz(2)/2;
        rect(4) = sz(1)/2;
        rect = round(rect);

    otherwise
        errordlg('No ROI Type selected');
end

cmin = rect(1); cmax = rect(1)+rect(3);
rmin = round(sz(1)/4); rmax = rect(2)+rect(4);

[c,r] = meshgrid(cmin:cmax,rmin:rmax);
roiLocs = [r(:),c(:)];

return;