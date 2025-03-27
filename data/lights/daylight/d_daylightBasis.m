%% d_cieDaylightBasis
%
% Starting to use d_* for data management scripts.  These will be in the
% data subdirectory, typically.  I may rename some of the sensor definition
% files or others that are around.  Just starting. (BW).
%
% The data were from a Judd Macadam and Wyszecki paper that the CIE adopted
% in a standard.  All around 1967.
%

chdir(fullfile(isetRootPath,'data','lights','daylight'));


%% We had this file for years.  I didn't throw it away yet.

ieNewGraphWin;
cieDaylightBasis = ieReadSpectra('cieDaylightBasis_original',dayBasis(:,1));

% Show the daylight bases.  These are not orthonormal.
ieNewGraphWin;
plot(dayBasis(:,1),cieDaylightBasis);
grid on; xlabel('Wave (nm)'); ylabel('Relative energy');
xaxisLine;

%% BW downloaded this csv file from the CIE site.  February 2, 2025.
%
% The data are the same as the one I typed in years ago from Judd et
% al. (except for one tiny error and the range) with the daylight
% function we used for many years. Since it is official, I overwrote
% the cieDaylightBasis

ieNewGraphWin;
dayBasis = readmatrix('CIE_illum_Dxx_comp.csv');
plot(dayBasis(:,1),dayBasis(:,2:4));
grid on; xlabel('Wave (nm)'); ylabel('Relative energy');
xaxisLine;

%% Only run this if are prepared to overwrite
comment = {'https://cie.co.at/datatable/components-relative-spectral-distribution-daylight',...
'Judd, Deane B., David L. MacAdam, Günter Wyszecki, H. W. Budde, H. R. Condit, S. T. Henderson, and J. L. Simonds. 1964. “Spectral Distribution of Typical Daylight as a Function of Correlated Color Temperature.” Journal of the Optical Society of America 54 (8): 1031.'};

ieSaveSpectralFile(dayBasis(:,1),...
    dayBasis(:,2:4),...
    comment,fullfile(isetRootPath,'data','lights','cieDaylightBasis.mat'));

%% Read it.

% The comment has the link to the CIE site and the reference to the JMW
% paper.

ieNewGraphWin;
[dayBasis,dayWave,comment] = ieReadSpectra('cieDaylightBasis');
plot(dayWave,dayBasis);

%% Checking the daylights

% The Granada and Stanford data sets are really quite similar, even in
% their basis sets.
% They are not that simlar, however to the CIE basis sets.
wave = 400:1:700;

% Stanford data set from J. DiCarlo
test1 = ieReadSpectra('daylightStanford',wave);
size(test1)
% ieFigure; plot(wave,test1);
[U1,~,~] = svd(test1,'econ');
U1 = U1(:,1:3);
if max(U1(:,1)) < 0, U1 = -1*U1; end
U1 = U1/max(U1(:));

% Granada from their web site
test2 = ieReadSpectra('daylightGranada',wave);
size(test2)
% ieFigure; plot(wave,test2);
[U2,~,~] = svd(test2,'econ');
if max(U2(:,1)) < 0, U2 = -1*U2; end
U2 = U2(:,1:3);
U2 = U2/max(U2(:));

% CIE official values from Judd, Macadam and Wyszecki
U3 = ieReadSpectra('cieDaylightBasis',wave);

%% The Stanford and Granada bases can be fit by the CIE bases

% And, the Granada and Stanford data are more similar than the CIE
% data.  The CIE fits miss the Stanford and Granada data in the 3rd
% component between 500 and 550 nm. Surprising, and somewhat useful to
% know.

ieFigure([],'wide');
tiledlayout(1,3);

% Stanford from CIE
% U1 = U3*T
nexttile
T = U3\U1;
U13 = U3*T;
plot(wave,U1,'k-',wave,U13,'b:');
subtitle('Stanford from CIE');

% Granada from CIE
% U2 = U3*T
nexttile;
T = U3\U2;
U23 = U3*T;
plot(wave,U2,'k-',wave,U23,'b:');
subtitle('Granada from CIE');

% Granada from Stanford
% U2 = U1*T
nexttile;
T = U1\U2;
U21 = U1*T;
plot(wave,U2,'k-',wave,U21,'b:');
subtitle('Granada from Stanford');
