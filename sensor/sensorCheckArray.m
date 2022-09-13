function img = sensorCheckArray(sensor,n)
% Visual check of the color filter array pattern
%
% Synopsis
%     sensorCheckArray(sensor,n)
%
% Input:
%   sensor - ISETCam image sensor
%   n      - size scale   (default 25)
%
% Output
%   img
%
% The routine produces an image that shows the color filter array pattern.
%
% See also
%   sensorData2Image
%

% Example:
%   img = sensorCheckArray(sensorCreate,128);
%

if ieNotDefined('n'), n = 64; end

% Find the pattern
pattern = sensorGet(sensor,'pattern');

% Create an image with max voltages in each pixel
mxVolts = sensorGet(sensor,'voltage swing');
ss = sensorSet(sensor,'volts',mxVolts*ones(size(pattern)));
cfaSmall = sensorData2Image(ss);

% Scale the image up in size for visibility
img = imageIncreaseImageRGBSize(cfaSmall,n);

% Show it.  Though we should be able to suppress this some day.
ieNewGraphWin;
imagescRGB(img);

% This used to be the call, but that is now deprecated.
% sensorImageColorArray(cfa);

end
