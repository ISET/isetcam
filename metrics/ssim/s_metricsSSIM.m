%% Experiments with ssim
%
% Scratch for now.  More to come.


%% Reference scene
scene = sceneCreate('macbeth',64);
sceneWindow(scene);

ref = sceneGet(scene,'rgb');
lumRef = sceneGet(scene,'luminance');

ieNewGraphWin; imshow(ref);
ieNewGraphWin; imagesc(lumRef); colormap("gray"); axis image

%%  Noisy scene

energy = sceneGet(scene,'energy');
sz = sceneGet(scene,'size');
nWave = sceneGet(scene,'n wave');
noise = randn(sz(1),sz(2),nWave);

% The noise has a mean close to zero
noise = noise .* ((energy.^0.5)*0.05);

scene2 = sceneSet(scene,'energy',energy + noise);
sceneWindow(scene2);

test = sceneGet(scene2,'rgb');
lumTest = sceneGet(scene2,'luminance');

ieNewGraphWin; imshow(test);
ieNewGraphWin; imagesc(lumTest); colormap("gray"); axis image

%%
montage({test,ref});
montage({lumTest,lumRef});


%%
ieNewGraphWin;
plot(test(1:10:end),ref(1:10:end),'.');

%%

mean(test(:) - photons(:))

test = ref + 0.1*randn(size(ref));
test(test>1) = 1;
ieNewGraphWin; imshow(test);

%%  Compute the luminance




[val,ssimmap] = ssim(test,ref);

montage({test,ref});
size(test)

%%
%{
for ii=1:3
    ieNewGraphWin;
    mesh(mp(:,:,ii));
end
%}
%%
ieNewGraphWin;
% Mean error across the three color channels

% SSIM 1 is highest quality.  We want this to be an error map, so we
% subtract from one.
imagesc(1 - mean(ssimmap,3)); axis image;
title('SSIM Error')
colorbar;

%% Try S-CIELAB on these images?

params = scParams;
fov = 15;
params.sampPerDeg = round(size(test,1)/fov);
testXYZ = ieClip(srgb2xyz(test),0,[]);
refXYZ  = ieClip(srgb2xyz(ref),0,[]);

dEimg = scielab(testXYZ,refXYZ,[.92 .98 .98],params);
% ieNewGraphWin;
% mesh(dEimg);
% mean(dEimg(:))

%%
ieNewGraphWin;
g = fspecial("gaussian",[27,27],9);
imagesc(conv2(dEimg,g)); axis image
title('SCIELAB Error')

%%