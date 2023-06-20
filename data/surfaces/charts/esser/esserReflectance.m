%% Initialize
ieInit;
%% Compare the radiance and the data from repo
% Read in the reflection
[data, wave] = ieReadSpectra('esserChartRadiance.mat');
ieNewGraphWin;
plot(wave, data);
% Extract the radiance from white patch
[v, idx] = max2(data);
white = data(:,idx(2));

% Calculate the reflectance
refl = diag(1./white) * data;

% These are the calculated 
ieNewGraphWin;
plot(wave, refl);

% These are from the record, same data.
[esserData, wave] = ieReadSpectra('esserChart.mat');
ieNewGraphWin;
plot(wave, esserData);