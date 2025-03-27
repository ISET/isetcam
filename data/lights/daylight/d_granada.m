% Granada daylight spectra
%
% Downloaded from their website (below) and converted to ISETCam
% spectral file.
%
% I compared with Stanford ones from Jeff and the CIE in d_daylightBasis.

% This is the drive in Wandell's office.
localdir = '/Volumes/TOSHIBA EXT/isetdata/Daylights';
localfile = 'skylight_1567_Granada.mat';
wave = 370:5:790;
load(fullfile(localdir,localfile));

%% Have a look and save
ieFigure;
semilogy(wave,skylight_Granada_1567);
ieSaveSpectralFile(wave,...
    skylight_Granada_1567,...
    'https://colorimaginglab.ugr.es/pages/data#__doku_granada_skylight_spectral_database', ...
    fullfile(isetRootPath,'data','lights','daylight','daylightsGranada.mat'));

%%