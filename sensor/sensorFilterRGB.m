function filterRGB = sensorFilterRGB(sensor,saturation)
%Return RGB values that approximate the sensor filter colors
%
%   filterRGB = sensorFilterRGB(sensor,saturation)
%
% Example:
%    saturation = 0.3;
%    sensor = vcGetObject('sensor');
%    filterRGB = sensorFilterRGB(sensor,saturation);
%    fmt    = '%.1f';  prompt = 'Time (ms)';
%    defMatrix = [ 25, 25 ; 30, 45];
%    ieReadSmallMatrix(size(defMatrix),defMatrix,fmt,prompt,[],'msExposureData',filterRGB);
%

if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('saturation'), saturation = 1; end

wave = sensorGet(sensor,'wave');

% Makes  infrared wavelengths show up as gray
irExtrapolation = 0.2;
bMatrix = colorBlockMatrix(wave,irExtrapolation);

pattern = sensorGet(sensor,'pattern');
nRows = size(pattern,1);
nCols = size(pattern,2);

filterRGB = zeros(nRows,nCols,3);
filterSpectra = sensorGet(sensor,'filterSpectra');
defaultBackground = get(0,'defaultUicontrolBackgroundColor');

% Make colors, but perhaps not fully saturated.
for ii = 1:nRows
    for jj = 1:nCols
        colorFilter = filterSpectra(:, pattern(ii,jj));
        rgb = bMatrix'*colorFilter;
        rgb = (rgb'/max(rgb(:)));
        filterRGB(ii,jj,:) = rgb* saturation + (1-saturation)*defaultBackground;
    end
end

return
