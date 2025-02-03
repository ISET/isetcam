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
% The data are the same as the one I typed in years ago from JMW (except
% for one tiny error and the range) with the daylight function we used for
% many years. Since it is official, I overwrote the cieDaylightBasis

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

%%