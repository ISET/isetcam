%% Jeff DiCarlo Stanford daylight data
%
%  Granada daylight data
%  See d_daylightBasis for some comparisons with CIE basis.

%% Stanford
% I am unsure about the time of day, and why there are so many more
% than there are daylight spectra.

[data,wave] = ieReadSpectra('daylightStanford',wave);

idx = randi(size(data,2),[1,20]);
ieFigure;
semilogy(wave,data(:,idx));
size(data)

% There must be a day to convert these numbers into a time and date.
load('daylightStanford.mat','timeOfDay');
timeOfDay(:,idx)

%% Granada

[data,wave] = ieReadSpectra('daylightGranada',wave);

idx = randi(size(data,2),[1,20]);
% Samples
ieFigure;
semilogy(wave,data(:,idx));

%%



