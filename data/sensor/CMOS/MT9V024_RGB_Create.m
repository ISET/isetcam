%% ON sensor data
%
% Deprecated
% Use MT9V024Create.m
%

%%
ieInit;

%% First, the RCCC because it's fun

% The spec sheet goes to the band gap (1100 nm).  But we don't go past 780.
%  So, we interpolate only to 780.  But remember if you need it some day,
%  it's there.

chdir(fullfile(isetRootPath,'data','sensor','CMOS','ON','RGB'));
load('redChannel.mat','RedChannel')
load('greenChannel.mat','GreenChannel')
load('blueChannel.mat','BlueChannel')

wave = 380:10:780;
R = interp1(RedChannel(:,1),RedChannel(:,2),wave,'linear','extrap');
R = R/100;

G = interp1(GreenChannel(:,1),GreenChannel(:,2),wave,'linear','extrap');
G = G/100;

B = interp1(BlueChannel(:,1),BlueChannel(:,2),wave,'linear','extrap');
B = B/100;

vcNewGraphWin; 
plot(wave,R,'r-',wave,G,'g-',wave,B,'b-');
grid on; xlabel('Wavelength (nm)'); ylabel('Responsivity')

%%
wave = iWave;
RGB = [R(:) G(:) B(:)];
cf.wavelength = wave;
cf.data = RGB;
cf.filterNames = {'r','g','b'};
cf.comment = 'Grabit from ON data sheet MT9V024-D.PDF in SCIEN 2017 Vehicle folder';
ieSaveColorFilter(cf,fullfile(isetRootPath,'data','sensor','CMOS','MT9V024_RGB.mat'));


%%  Check that we can read it and plot it

[data,filterNames,fileData] = ieReadColorFilter(wave,'MT9V024_RGB.mat');
% plot(wave,data)
filterNames

%%
