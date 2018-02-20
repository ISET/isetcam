% Create four channel sensor for some test analyses.
%
% This is a fabricated sensor.
%

wave = 400:1:700;

cmyFile = fullfile(isetRootPath,'data','sensor','colorfilters','CMY');
[cmyData,cmyFilterNames] = ieReadColorFilter(wave,cmyFile);

gFile = fullfile(isetRootPath,'data','sensor','colorfilters','G');
[gData,gFilterNames] = ieReadColorFilter(wave,gFile);

% Merge the data sets
data = [cmyData,gData];
filterNames = cellMerge(cmyFilterNames,gFilterNames);

% Fastest way to save the color filter is to dummy up a sensor, add the
% filters and filternames, and have ieSaveColorFilter pull everything out
% for us.
sensor = sensorCreate;
sensor = sensorSet(sensor,'wave',wave);
sensor = sensorSet(sensor,'colorfilters',data);
sensor = sensorSet(sensor,'filterNames',filterNames);
fName = fullfile(isetRootPath,'data','sensor','colorfilters','CMYG.mat');
ieSaveColorFilter(sensor,fName);

