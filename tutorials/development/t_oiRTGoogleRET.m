%% init
ieInit;

%% Parameters initialization
fullFOV = 77;
halfFOV = 35;
wave = 450:50:650;
%% Load optics
%{
oi = oiCreate('ray trace');
optics = oiGet(oi, 'optics');
isetParmsFile = vcSelectDataFile('stayput','r','txt',...
    'Select the ISETPARMS.txt file');
optics = rtImportData(optics, 'zemax', isetParmsFile);
%}
load('isetLensG.mat');
%% Read in larger images
imgPathFullFOV = fullfile(isetRootPath, 'local', 'imgsFromGoogle', 'optics',...
    'RET_5920_60cm_8M_77HFOV.png');

imgFullFOV = imread(imgPathFullFOV);
szFullFOV = size(imgFullFOV); % Get the size of image
frameRatio = szFullFOV(2) / szFullFOV(1);
%% Calculate the image resollution for half FOV

distance = opticsGet(optics, 'rt object distance');

% Calculate actual width for halfFOV and fullFOV
widthHalfFOV = 2 * distance * tand(halfFOV/2); % Physical width of the scene (meters)
widthFullFOV = 2 * distance * tand(fullFOV/2); % Same for the full fov

nPixelWidthHalfFOV = szFullFOV(2) * widthHalfFOV / widthFullFOV;
nPixelHeightHalfFOV = nPixelWidthHalfFOV / frameRatio;

%% Crop image for half FOV from center
szDiff = [floor((szFullFOV(1) - nPixelHeightHalfFOV)/2),...
    floor((szFullFOV(2) - nPixelWidthHalfFOV)/2)];

cropRect = [szDiff(2)+1, szDiff(1)+1, floor(nPixelWidthHalfFOV)-1, ...
    floor(nPixelHeightHalfFOV)];

imgHalfFOV = imcrop(imgFullFOV, cropRect);

% Check the size of the image
% ieNewGraphWin; imshow(imgHalfFOV);
szHalfFOV = size(imgHalfFOV);

%% Save the half fov image
imgSavePath = fullfile(isetRootPath, 'local', 'imgsFromGoogle', 'optics',...
    'RET_5920_60cm_8M_35HFOV_double.png');
imwrite(imgHalfFOV, imgSavePath);

%% Check if the image is correctly cropped
imgHalfFOVPd = uint8(zeros(szFullFOV));
imgHalfFOVPd(cropRect(2):cropRect(2)+cropRect(4),...
    cropRect(1):cropRect(1)+cropRect(3), :) = imgHalfFOV;

ieNewGraphWin;
imagesc(imgFullFOV - imgHalfFOVPd); % Center is empty

%% Use sceneFromFile to generate scene
imgPathHalfFOV = imgSavePath;
sceneHalfFOV = sceneFromFile(imgPathHalfFOV, 'rgb',[], [], wave);
sceneHalfFOV = sceneSet(sceneHalfFOV, 'distance', distance);
%% Set scene parameters

% First set the optics to an oi Object
oiHalfFOV = oiCreate('ray trace');
oiHalfFOV = oiSet(oiHalfFOV, 'optics', optics);
oiHalfFOV = oiSet(oiHalfFOV, 'optics off axis method', 'cos4th');
% Get focal length
focalLength = oiGet(oiHalfFOV, 'optics rt effective focal length', 'm'); % In meters

% Calculate horizontal FOV set to scene
pixelSize = 1.2e-6; % 1.2 um for sensor pixel

szSceneHalfFOV = sceneGet(sceneHalfFOV, 'size');
nPixel = szSceneHalfFOV(2);

% Width of the sensor in meters
widthHalfFOV = pixelSize * nPixel;

% Calculate scene hFOV
hHalffov = 2 * atand(widthHalfFOV/(2*focalLength) ); % Scene hFOV
sceneHalfFOV = sceneSet(sceneHalfFOV, 'fov', hHalffov);
ieAddObject(sceneHalfFOV);

% sceneWindow(sceneHalfFOV)

%% Compute optical image
oiHalfFOV = oiCompute(oiHalfFOV, sceneHalfFOV);
oiHalfFOV = oiSet(oiHalfFOV, 'name', sprintf('Render with FOV: %.4f', hHalffov));

%% Now do the same things for full FOV
% Load scene
sceneFullFOV = sceneFromFile(imgPathFullFOV, 'rgb', [], [], wave);

% Set the distance
sceneFullFOV = sceneSet(sceneFullFOV, 'distance', distance);

% Set scene parameters
szSceneFullFOV = sceneGet(sceneFullFOV, 'size');
nPixel = szSceneFullFOV(2);

% Width of sensor in meters;
widthFullFOV = pixelSize * nPixel;

% Calculate scene hFOV
hFullfov = 2 * atand(widthFullFOV/(2*focalLength) ); % Scene hFOV
sceneFullFOV = sceneSet(sceneFullFOV, 'fov', hFullfov);
ieAddObject(sceneFullFOV);

% sceneWindow(sceneFullFOV)

%% Optics image for full FOV
oiFullFOV = oiCreate('ray trace');
oiFullFOV = oiSet(oiFullFOV, 'optics', optics);
oiFullFOV = oiSet(oiFullFOV, 'optics off axis method', 'cos4th');

oiFullFOV = oiCompute(oiFullFOV, sceneFullFOV);
oiFullFOV = oiSet(oiFullFOV, 'name', sprintf('Render with FOV: %.4f', hFullfov));

%% Display the oi images for half FOV and full FOV
oiWindow(oiHalfFOV);
oiWindow(oiFullFOV);

%% Get rgb image preview of optical image
rgbOIHalfFOV = oiGet(oiHalfFOV, 'rgb image');
rgbOIFullFOV = oiGet(oiFullFOV, 'rgb image');

% Crop padding black region
rgbOIHalfFOV = imcrop(rgbOIHalfFOV, [17, 17, szHalfFOV(2)-1, szHalfFOV(1)-1]);
rgbOIFullFOV = imcrop(rgbOIFullFOV, [17, 17, szFullFOV(2)-1, szFullFOV(1)-1]);

%{

% Preview image
ieNewGraphWin;
imshow(rgbOIHalfFOV);
title(sprintf('Optical image with FOV: %.4f', hHalffov));

ieNewGraphWin;
imshow(rgbOIFullFOV);
title(sprintf('Optical image with FOV: %.4f', hFullfov));

%}

%% Write out images
halfFOVSavePath = fullfile(isetRootPath, 'local', 'imgsFromGoogle', 'optics',...
    'RET_5920_60cm_8M_35HFOV_OI_ZL.bmp');
imwrite(rgbOIHalfFOV, halfFOVSavePath);

fullFOVSavePath = fullfile(isetRootPath, 'local', 'imgsFromGoogle', 'optics',...
    'RET_5920_60cm_8M_77HFOV_OI_ZL.bmp');
imwrite(rgbOIFullFOV, fullFOVSavePath);
%% Finally compare the difference within half fov region
rgbOIHalfFOVPd = single(zeros(szFullFOV));
rgbOIHalfFOVPd(cropRect(2):cropRect(2)+cropRect(4),...
    cropRect(1):cropRect(1)+cropRect(3), :) = rgbOIHalfFOV;

% Visualize the difference of the two images
ieNewGraphWin;
imagesc(rgbOIFullFOV - rgbOIHalfFOVPd);

%% Or compare the center part of full fov region
rgbOIFullFOVCrp = rgbOIFullFOV(cropRect(2):cropRect(2)+cropRect(4),...
    cropRect(1):cropRect(1)+cropRect(3), :);

% Visualize the difference of the two images
ieNewGraphWin;
imagesc(rgbOIFullFOVCrp - rgbOIHalfFOV);

%% Try using getMiddleMatrix
% rgbOIFullFOVCrp2 = getMiddleMatrix()