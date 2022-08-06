%% Daylight from Jeff DiCarlo data

jdDaylights = load('daylightSpectra.mat');
data = jdDaylights.data;
wave = jdDaylights.wavelength;
ieNewGraphWin;
plot(wave,data(:,1:50:end));
t = jdDaylights.timeOfDay;
