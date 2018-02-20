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

chdir(fullfile(isetRootPath,'data','sensor','CMOS','ON','MONO'));
load('Mono.mat','Mono')

wave = 380:10:780;
W = interp1(Mono(:,1),Mono(:,2),wave,'linear','extrap');
W = W/100;

vcNewGraphWin; 
plot(wave,W,'k-');
grid on; xlabel('Wavelength (nm)'); ylabel('Responsivity')

%%
wave = iWave;
Mono = [W(:)];
cf.wavelength = wave;
cf.data = Mono;
cf.filterNames = {'w'};
cf.comment = 'Grabit from ON data sheet MT9V024-D.PDF in SCIEN 2017 Vehicle folder';
ieSaveColorFilter(cf,fullfile(isetRootPath,'data','sensor','CMOS','MT9V024_Mono.mat'));


%%  Check that we can read it and plot it

[data,filterNames,fileData] = ieReadColorFilter(wave,'MT9V024_Mono.mat');
% plot(wave,data)
filterNames

%%
