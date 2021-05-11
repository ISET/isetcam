function [sensorImg, sensorSD, cornerPoints] = macbethSensorValues(sensor, showSelection, cornerPoints)
% Deprecated:
%
%   Replaced by chart code such as
%    cp = chartCornerpoints(sensor,false);  % Get the corner points
%    [rects,mLocs,pSize] = chartRectangles(cp,4,6,0.5);
%    fullData = false;
%    dataType = 'dvorvolts';
%    delta = round(pSize(1)*0.5);
%    data = chartRectsData(sensor,mLocs,delta,fullData,dataType);
%
%   Identify MCC patches and calculate RGB mean (s.d.) of the 24 patches
%
%   [sensorImg,sensorSD,cornerPoints] = macbethSensorValues(sensor,showSelection,cornerPoints);
%
% This routine is designed to analyze sensor RGB values.  It calculates how
% to (linearly) transform the sensor RGB into the ideal RGB values for and
% MCC target.  We can find this transform by
%
%   idealLRGB = sensorImg L(3x3)
%
% The transform can be adjusted to minimize different types of errors, such
% as the achromatic series, delta E, or RMSE.  More routines will be
% developed for this purpose.  If we find the transform L in different
% circumstances, say different ambient lighting for the MCC, then we can
% build up a whole set that is appropriate for color balancing.
%
% See also macbethSelect, macbethCompareIdeal
%
% Example:
%   sensor = vcGetObject('sensor');
%   [sensorImg,sensorSD,cornerPoints] = macbethSensorValues(sensor,1);
%
% Copyright ImagEval Consultants, LLC, 2005.

%%
if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('showSelection'), showSelection = true; end
fullData = true;

%% Get the raw sensor data
if ieNotDefined('cornerPoints')
    [fullRGB, mLocs, pSize, cornerPoints] = macbethSelect(sensor, showSelection, fullData);
else
    [fullRGB, mLocs, pSize, cornerPoints] = macbethSelect(sensor, showSelection, fullData, cornerPoints);
end

nSensors = size(fullRGB{1}, 2);
sensorImg = zeros(24, nSensors);
if nargout == 2, sensorSD = zeros(24, nSensors);
else, sensorSD = [];
end

% Fix up the NaNs for the sensor data
for ii = 1:24 % For each chip
    tmp = fullRGB{ii};
    for band = 1:nSensors % For each band
        foo = tmp(:, band);
        sensorImg(ii, band) = mean(foo(~isnan(foo)));
        if nargout == 2, sensorSD(ii, band) = std(foo(~isnan(foo))); end
    end
end

end