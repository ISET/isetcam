function sensor = fourChannelCreate(varargin)
% Create four channel RGBW sensor for some test analyses.
%
% This is a fabricated sensor.
%
% 

% Example:

%
wave = 400:1:700;

rgbFile = fullfile(isetRootPath,'data','sensor','colorfilters','RGB');
[rgbData,rgbFilterNames] = ieReadColorFilter(wave,rgbFile);

wFile = fullfile(isetRootPath,'data','sensor','colorfilters','W');
[wData,wFilterNames] = ieReadColorFilter(wave,wFile);

% Merge the data sets
data = [rgbData, 0.25*wData];
filterNames = cellMerge(rgbFilterNames,wFilterNames);

% Fastest way to save the color filter is to dummy up a sensor, add the
% filters and filternames, and have ieSaveColorFilter pull everything out
% for us.
sensor = sensorCreate;
sensor = sensorSet(sensor,'wave',wave);
sensor = sensorSet(sensor,'colorfilters',data);
sensor = sensorSet(sensor,'filterNames',filterNames);


% fName = fullfile(isetRootPath,'data','sensor','colorfilters','RGBW.mat');
% ieSaveColorFilter(sensor,fName);

end


