function [combinedVoltImage, vImages, irFilters] = sensorComputeSVFilters(sensor, oi, filterFile)
% sensorCompute but with space varying irFilter
%
%   [combinedVoltImage, vImages, irFilters] = sensorComputeSVFilters(sensor,oi,filterFile)
%
% **** Under development.  Not ready for use. ***
%
% sensor:   ISET sensor
% oi:       ISET oi
% filterFile:  A file containing a matrix of filters along with the field
%              heights where each filter should be applied.
% Example:
%   combinedVoltImage = sensorComputeSVFilters(sensor,oi,filterFile)
%   sensor = sensorSet(sensor,'volts',combinedVoltImage);
%
% Copyright Imageval, 2010

%% Set up the arguments
if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('oi'), oi = vcGetObject('oi'); end
if ieNotDefined('filterFile')
    filterFile = vcSelectDataFile('stayput', 'r', 'mat', 'Select filter file');
    if isempty(filterFile), disp('User canceled');
        return;
    end
end

%% Read the IR filters
wave = sensorGet(sensor, 'wave');
[irFilters, irFilterNames, irFilterAllData] = ieReadColorFilter(wave, filterFile);

% Create a map showing the field height (degrees) for each pixel in the
% sensor. This measures the angle from the center (on-axis) pixel.
optics = oiGet(oi, 'optics');
sensorDegMap = sensorGet(sensor, 'chiefRayAngleDegrees', opticsGet(optics, 'focalLength'));
% figure(1); mesh(deg)

mx = max(sensorDegMap(:));
idx = find(irFilterAllData.fHeight <= mx);
fHeights = irFilterAllData.fHeight(idx);
irFilters = irFilters(:, idx);
nFilters = length(idx);

%% Compute the voltage images for this sensor with each of the filters

sz = sensorGet(sensor, 'size');
vImages = zeros(sz(1), sz(2), nFilters);
for ii = 1:nFilters
    sensor = sensorSet(sensor, 'irFilter', irFilters(:, ii));
    sensor = sensorCompute(sensor, oi);
    vImages(:, :, ii) = sensorGet(sensor, 'volts');
end

%% Combine the voltage images into a single voltage image

combinedVoltImage = zeros(size(vImages(:, :, 1)));

% Find the pixels in between each pair of field heights.
for ii = 2:nFilters
    % Ones at the locations in this band
    thisBand = (fHeights(ii - 1) < sensorDegMap) & (sensorDegMap < fHeights(ii));
    % figure(1); imagesc(thisBand)

    innerDistance = abs(sensorDegMap-fHeights(ii - 1));
    % figure(1); mesh(double(innerDistance));

    innerWeight = 1 - (innerDistance / (fHeights(ii) - fHeights(ii - 1)));
    innerWeight(~thisBand) = 0;
    % figure(1); imagesc(innerWeight)
    % max(innerWeight(thisBand)), min(innerWeight(thisBand))

    weightedImage = innerWeight .* vImages(:, :, ii-1) + (1 - innerWeight) .* vImages(:, :, ii);
    combinedVoltImage(thisBand) = weightedImage(thisBand);
    % figure(1); imagesc(combinedVoltImage);

end

end
