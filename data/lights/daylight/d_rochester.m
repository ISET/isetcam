%% Read in the Rochester data
%
% I think these are part of the Judd et al. measurments
%

tmp = readmatrix('Daylight Rochester NY 14623.xls');
wave = tmp(2:end,1);
spd = tmp(2:end,2:end);
ieFigure;
plotRadiance(wave,spd); title('Rochester skylights');
fname = ieSaveSpectralFile(wave,spd,'Daylight Rochester NY 14623 spread sheet','daylightRochester.mat');

%% Check

%{
wave = 400:10:750;
data = ieReadSpectra('daylightRochester.mat',wave);
ieFigure; 
plotRadiance(wave,data);
%}