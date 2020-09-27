%% s_dcraw
%
% Experiment with simple dcraw data. 

%% Try it in the dcraw utility directory
chdir(fullfile(isetRootPath,'utility','external','dcraw'));
remoteD = 'http://scarlet.stanford.edu/validation/SCIEN/L3/nikond200';

%% Get the PGM file (raw data)

% Many potential files
% remoteF = 'PGM/DSC_0767.pgm';
remoteF = 'PGM/DSC_0803.pgm';

fname = fullfile(remoteD,remoteF);
[~,status] = urlwrite(fname,'rawFile.pgm');
raw = imread('rawFile.pgm');
vcNewGraphWin; imagesc(raw); 
colormap(gray(1024)); axis image

% vcNewGraphWin; hist(single(raw(:)),100)

%% Now get the corresponding JPG data

% Corresponding JPG files
% remoteF = 'JPG/DSC_0767.JPG';
remoteF = 'JPG/DSC_0803.JPG';
fname = fullfile(remoteD,remoteF);
[~,status] = urlwrite(fname,'jpgFile.jpg');
jpg = imread('jpgFile.jpg');
% 0803 needs a rotate
% jpg = imrotate(jpg,90);
vcNewGraphWin; imagesc(jpg); 
colormap(gray(1024)); axis image

% vcNewGraphWin; hist(single(jpg(:)),100)

%%

