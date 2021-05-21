%% Tutorial for ray tracing optics image calculation using ggl lens

%% Init
ieInit;

%% Select a smaller rectangle crop
sceneOne = sceneCreate('point array',1024, 128);
sceneOne = sceneSet(sceneOne, 'name', 'Point array with smaller fov');
sceneOne = sceneSet(sceneOne, 'distance', 0.6);
sceneOne = sceneSet(sceneOne, 'wave', 430:50:650);

%% Calculate horizontal FOV set to scene
% Given (1) sensor pixel size and (2) size of the scene representation
% image, what is the horizontal FOV that should be set to scene
pixelSize = 1.2e-6; % 1.2 um for sensor pixel
load('lensmatfile.mat', 'optics');

oiOne = oiCreate('ray trace');
oiOne = oiSet(oiOne, 'optics', optics);

focalLength = oiGet(oiOne, 'optics rteffectivefocallength', 'm'); % In meters

sz = sceneGet(sceneOne, 'size');
nPixels = sz(2);
% This is the width of the sensor in meters
width = pixelSize * nPixels;

hfov = 2 * atand(width/(2*focalLength) ); % Scene hFOV
sceneOne = sceneSet(sceneOne, 'fov', hfov);
ieAddObject(sceneOne);
% sceneWindow(sceneOne)
%%
oiOne = oiCompute(oiOne, sceneOne);
oiOne = oiSet(oiOne, 'name', 'render with smaller fov');
oiWindow(oiOne);
oiImgOne = oiGet(oiOne, 'rgb image');
%% Now let's do the same thing for a larger rectangle crop
sceneTwo = sceneCreate('point array', 2048, 128);
sceneTwo = sceneSet(sceneTwo, 'name', 'Point array with larger fov');
sceneTwo = sceneSet(sceneTwo, 'distance', 0.6);
sceneTwo = sceneSet(sceneTwo, 'wave', 430:50:650);

%%
sz = sceneGet(sceneTwo, 'size');
nPixels = sz(2);
% This is the width of the sensor in meters
width = pixelSize * nPixels;

hfov = 2 * atand(width/(2*focalLength) ); % Scene hFOV
sceneTwo = sceneSet(sceneTwo, 'fov', hfov);
ieAddObject(sceneTwo);
% sceneWindow(sceneTwo)

%%
oiTwo = oiCreate('ray trace');
oiTwo = oiSet(oiTwo, 'optics', optics);

%% Double the max fov for lens
rtFov = opticsGet(optics, 'rtfov');
oiTwo = oiSet(oiTwo, 'optics rtfov', rtFov * 2);
oiTwo = oiCompute(oiTwo, sceneTwo);
oiTwo = oiSet(oiTwo, 'name', 'render with larger fov (larger max lens fov)');
oiWindow(oiTwo);

oiImgTwo = oiGet(oiTwo, 'rgb image');

%% Analysis of two images
sizeImgOne = size(oiImgOne);
sizeImgTwo = size(oiImgTwo);

% Crop imgOne with zeros

oiImgOnePd = imcrop(oiImgOne, [17, 17, 1023, 1023]);
oiImgTwoPd = imcrop(oiImgTwo, [17, 17, 2047, 2047]);

sizeDiff = (size(oiImgTwoPd) - size(oiImgOnePd))/2;

oiImgTwoPd = imcrop(oiImgTwoPd,...
    [sizeDiff(1)+1, sizeDiff(2)+1, size(oiImgOnePd, 1)-1, size(oiImgOnePd, 2)-1]);

%{

ieNewGraphWin;
imshow(oiImgOnePd);
title(sprintf('Optical image for scene with FOV %.2f',...
                sceneGet(sceneOne,'hfov')));

ieNewGraphWin;
imshow(oiImgTwoPd);
title(sprintf('Optical image for scene with FOV %.2f',...
                sceneGet(sceneTwo,'hfov')));
    %}
    %%
    oiImgDiff = oiImgTwoPd - oiImgOnePd;
    
    ieNewGraphWin;
    imagesc(oiImgDiff(:,:,1));
    title('Red channel');
    
    ieNewGraphWin;
    imagesc(oiImgDiff(:,:,2));
    title('Green channel');
    
    ieNewGraphWin;
    imagesc(oiImgDiff(:,:,3));
    title('Blue channel');
