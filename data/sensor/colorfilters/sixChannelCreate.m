% Create six channel sensor for some test analyses.
%
% This is a fabricated sensor.
%

wave = 400:1:700;

% Read cmy and then rgb data examples
cymFile = fullfile(isetRootPath, 'data', 'sensor', 'colorfilters', 'cym');
[cmyData, cmyFilterNames] = ieReadColorFilter(wave, cymFile);

rgbFile = fullfile(isetRootPath, 'data', 'sensor', 'colorfilters', 'rgb');
[rgbData, rgbFilterNames] = ieReadColorFilter(wave, rgbFile);

% Merge the data sets
data = [rgbData, 0.35 * cmyData];
filterNames = cellMerge(rgbFilterNames, cmyFilterNames);

% The structure for the color filter contains (minimally)
%  inData.wavelength;  % Vector of W wavelength samples
%  inData.data;        % Matrix of filters (W rows, N filter columns)
%  inData.filterNames; % Cell array of names; first letter is a color hint
sensor = sensorCreate;
sensor = sensorSet(sensor, 'wave', wave);
sensor = sensorSet(sensor, 'colorfilters', data);
sensor = sensorSet(sensor, 'filterNames', filterNames);
fName = fullfile(isetRootPath, 'data', 'sensor', 'colorfilters', 'sixChannel.mat');
ieSaveColorFilter(inData, fName);
