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
h = sz(1)/10;
imgH = imgaussfilt(img,h);
ieNewGraphWin; imagesc(imgH);

%% Convert the image to a hyper spectral cube
% 
% This code does not work because of sceneFromFile.  The relevant case
% was stripped out of sceneFromFile.  It may be in some other branch,
% or one of the students might have it in their personal space.
%
%[illScene, wgts, basisF] = sceneFromFile(imgH,'rgb',50,'cieDaylightBasis',...
%                                            wave, 'xyznonneg');

%{
wave = sceneGet(scene,'wave');
illScene = sceneFromFile(imgH,'rgb',50,'cieDaylightBasis',...
                                            wave, 'xyznonneg');

energy = sceneGet(illScene, 'energy');
[wgtXW, r, c] = RGB2XWFormat(wgts);
energyBasis = XW2RGBFormat((wgtXW * basisF'), r, c);
fprintf('Max difference of energy between calculated and recon: %.9f\n',...
        max(energy(:) - energyBasis(:)));
fprintf('Min energy value: %f\n', min(energy(:)));
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
%}

%%