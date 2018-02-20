%% Convert Gretag.bmp to a plausible gbrg sensor data file
%
% The image created is in a one channel TIF file and the entries represent
% the voltages at each color pixel (GBRG format).
%
% This image is useful for reading into the sensor image window and
% demonstrating ISET features.  The data in this image are not precisely
% the same as the data we use for accurate MCC renderings.  So the related
% script has some error in the attempted correct.  I think that's OK (or
% even useful).
%
% See also:  s_RAWMCC2Sensor
%
% Copyright ImagEval Consultants, LLC, 2010.

%% Read the BMP file

fName = 'Gretag.bmp';
mosaic = imread(fName);       % We are treating these as sensor volts
mosaic = double(mosaic)/255;  % imwrite needs [0,1]

%% Convert to the gb/rg format

% Initialize
r = size(mosaic,1);
c = size(mosaic,2);
sensorMosaic = zeros(r,c);

% Two green samples
sensorMosaic(1:2:end,1:2:end) = mosaic(1:2:end,1:2:end,2);
sensorMosaic(2:2:end,2:2:end) = mosaic(2:2:end,2:2:end,2);

% Blue sample
sensorMosaic(1:2:end,2:2:end) = mosaic(1:2:end,2:2:end,3);

% Red sample
sensorMosaic(2:2:end,1:2:end) = mosaic(2:2:end,1:2:end,1);

% A monochrome image, sampled for GBRG format
% imtool(sensorMosaic)

%% Write the data as a single image plane

fname = fullfile(isetRootPath,'data','sensor','gbrgMCCSensor.tif');
imwrite(sensorMosaic,fname,'tif');

%%