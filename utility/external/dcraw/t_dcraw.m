%% s_dcraw
%
% Examples of using dcraw
%
% So far we have only the example of the Adobe digital negative (dng) file
% format.  Others may arise, such as the Nikon NEF format.
%

%% DNG file reading

% This DNG file is from the Pixel 4 camera.  It is checked in and we can always
% test with this one.
fname = fullfile(isetRootPath, 'data', 'images', 'rawcamera', 'MCC-centered.dng');

% These worked too, once.
%{
fname = fullfile(igRootPath,'local','cornellbox','IMG_20200926_111217.dng');
fname = fullfile(igRootPath,'local','mcc','IMG_20200926_110536_1.dng');
%}

if ~exist(fname, 'file')
    error('No file found %s\n', fname);
else
    [img] = dcrawRead(fname);
    info = imfinfo(fname);
    info2 = dcrawInfo(fname); % Shorter version
    isoSpeed = info.DigitalCamera.ISOSpeedRatings;
    exposureTime = info.DigitalCamera.ExposureTime;
end

%
ieNewGraphWin;
imagesc(double(img).^(1 / 2.2));
axis image;
colormap(gray)

%{
% These are old notes about how we used to read the Nikon files for the L3 code.
% We need to update this code, depending on where the Nikon data currently are.

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
%}
