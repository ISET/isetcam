%% Experiments with ssim
%
% Scratch for now.  More to come.


scene = sceneCreate('macbeth',64);
sceneWindow(scene);

ref = sceneGet(scene,'rgb');

test = ref + 0.1*randn(size(ref));
test(test>1) = 1;

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