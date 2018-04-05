%% MT9V024 - ON RCCC image sensor
%
% JEF stored PDFs defining several of the properties of these ON sensors on
% our Google Drive, SCIEN, Papers, 2017 Vehicle Evaluation folder.  This
% script reads in the spectral response curves of the sensors and sets some
% of the other features so we can use them in simulation.
%
% There are separate files for the RGB and Monochrome sensors (AR0132AT)
% and (TBD)
%
% Copyright Imageval LLC, 2017

%%
ieInit;

%% Create the RCCC spectral sensor

% The spec sheet goes to the band gap (1100 nm).  But we don't go past 780.
% So, we interpolate only to 780.  But remember if you need it some day,
% it's there.

chdir(fullfile(isetRootPath,'data','sensor','CMOS','ON','RCCC'));
load('r_RCCC.mat','r_RCCC')
wave = r_RCCC(:,1);
R = r_RCCC(:,2);
iWave = 380:10:780;
R = interp1(wave,R,iWave,'linear','extrap');
R = R/100;

load('c_RCCC.mat','c_RCCC')
wave = c_RCCC(:,1);
C = c_RCCC(:,2);
C = interp1(wave,C,iWave,'linear','extrap');
C = C/100;

vcNewGraphWin; 
plot(iWave,C,'k-',iWave,R,'r-');
grid on; xlabel('Wavelength (nm)'); ylabel('Responsivity')

%%
wave = iWave;
ONRC = [R(:) C(:)];
cf.wavelength = wave;
cf.data = ONRC;
cf.filterNames = {'r','w'};
cf.comment = 'Grabit from ON data sheet MT9V024-D.PDF in SCIEN 2017 Vehicle folder';
ieSaveColorFilter(cf,fullfile(isetRootPath,'data','sensor','CMOS','MT9V024_RCCC.mat'));

%%
