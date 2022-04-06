%% Create interesting spatial spectral illuminants from an image
%

%%
ieInit

%% Make a scene
scene = sceneCreate('frequency orientation');
sz = sceneGet(scene,'size');
%% Pick an image
img = imread("cloudysky.png");

%% Resize the image to match the scene
% We should probably crop.
img = imresize(img,sz);
ieNewGraphWin; imagesc(img);

%% Blur the image by some amount
h = sz(1)/4;
imgH = imgaussfilt(img,h);
ieNewGraphWin; imagesc(imgH);

%% Convert the image to a hyper spectral cube
wave = sceneGet(scene,'wave');
illScene = sceneFromFile(imgH,'rgb',100,'',wave);
sceneWindow(illScene);

%% Remove the current illuminant and apply the new illuminant
illP = sceneGet(illScene,'photons');

scene = sceneIlluminantSS(scene);
oldIll = sceneGet(scene,'illuminant photons');
photons = sceneGet(scene,'photons');
photons = (photons ./ oldIll) .* illP;

scene = sceneSet(scene,'photons',photons);
scene = sceneSet(scene,'illuminant photons',illP);
sceneWindow(scene);

%%