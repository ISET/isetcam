%% Managing the IMX490 spectral QE
%
% Grabit on the scanned image in sonyIMX490.png produced the first
% file.

%%
datadir = fullfile(isetRootPath,'data','sensor','colorfilters','auto','SONY');
curdir = pwd;
chdir(datadir);

%% Data from grabit, via Zhenyi
tmp = load('qe_imx490_scan.mat');

% Scale to 0,1
tmp.data = tmp.data/100;

tmp.data(tmp.data<0) = 0;
tmp.data(isnan(tmp.data)) = 0;

ieNewGraphWin; plot(tmp.wavelength,tmp.data);
xaxisLine;

%% Write it out in the two formats.   Not sure why we have two.

%% CF file
tmp.filterNames = {'r','g','b'};
tmp.comment = 'Cleaned up QE from grabit scan of LUCID curves.';

cfFile = fullfile(datadir,'cf_imx490.mat');

ieSaveColorFilter(tmp,cfFile);
disp("Saved Sony imx490 spectral qe as a color filter.")
disp('Read it using ieReadColorFilter')

%% QE file
qeFile = fullfile(datadir,'qe_imx490.mat');
ieSaveSpectralFile(tmp.wavelength,tmp.data,tmp.comment,qeFile);
disp("Saved Sony imx490 spectral qe as a color filter.")
disp('Read it using ieReadSpectra.')

%%
