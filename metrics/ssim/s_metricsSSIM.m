%% Experiments with ssim
%
% Scratch for now.  More to come.


%%
ieInit;

%% Reference scene
scene = sceneCreate('sweep frequency',512,20);
sceneWindow(scene);

ref = sceneGet(scene,'rgb');
% refLum = sceneGet(scene,'luminance');
refLum = sum(ref,3)/3;

%%  Add photon noise
%
% scene = sceneAddNoise(scene,varargin)
%
% Add Poisson noise to the scene photons
% Or add Gaussian noise with mean and sd specified in varargin
%
photons = sceneGet(scene,'photons');
sz = sceneGet(scene,'size');
nWave = sceneGet(scene,'n wave');
photons2 = photons + randn(sz(1),sz(2),nWave).* photons.*(0.5);

scene2 = sceneSet(scene,'photons',photons2);
sceneWindow(scene2);

test = sceneGet(scene2,'rgb');
% testLum = sceneGet(scene2,'luminance');
testLum = sum(test,3)/3;

%%
ieNewGraphWin;
montage({ref,test});

% To make life simpler, and because SSIM doesn't care, we scale the lum
mx = max(max(lumTest(:)),max(lumRef(:)));
lumTest = lumTest/mx;
lumRef  = lumRef/mx;

ieNewGraphWin;
montage({lumTest,lumRef});

%% 24 patches.  Poisson noise illustrated

ieNewGraphWin;
plot(lumRef(1:10:end),lumTest(1:10:end),'k.');
identityLine; grid on;

%% The three measures

% None of this closely matches the Matlab calculation.
% I should figure out why.  So many possible reasons.

% SSIM constants when image is scaled between 0 and 1
C1 = 0.01^2;
C2 = 0.03^2;
C3 = C2/2;

ux = mean(lumRef(:));
uy = mean(lumTest(:));

sdx = std(lumRef(:));
sdy = std(lumTest(:));

tmp = cov(lumRef,lumTest);
sxy = tmp(1,2);

% Global formula
((2*ux*uy + C1)*(2*sxy + C2)) / ((ux^2 + uy^2 + C1)*(sdx^2 + sdy^2 + C2))

%%  Compute the luminance

[val,ssimmap] = ssim(test,ref);

% SSIM 1 is highest quality.  We want this to be an error map, so we
% subtract from one.
ieNewGraphWin;
imagesc(1 - mean(ssimmap,3)); axis image;
title('SSIM Error')
colorbar; axis image; axis off

%%

ieNewGraphWin;
mesh(1 - mean(ssimmap,3));

%% Try S-CIELAB on these images?

params = scParams;
fov = 40;
params.sampPerDeg = round(size(test,1)/fov);
testXYZ = ieClip(srgb2xyz(test),0,[]);
refXYZ  = ieClip(srgb2xyz(ref),0,[]);

dEimg = scielab(testXYZ,refXYZ,[.92 .98 .98],params);
ieNewGraphWin; imagesc(dEimg);
colorbar; axis image; axis off


% ieNewGraphWin;
% mesh(dEimg);
% mean(dEimg(:))

%%
ieNewGraphWin;
g = fspecial("gaussian",[27,27],9);
imagesc(conv2(dEimg,g)); axis image
title('SCIELAB Error')

%%