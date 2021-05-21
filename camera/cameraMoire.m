function metric = cameraMoire(camera)

% metric = cameraMoire(camera)
%
% Moire ....
%
% Output is a structure containing all results.

scene = sceneCreate('moire orient');
% scene = sceneCreate('zone plate',[1000,1000]); %sz = number of pixels of scene

meanLuminance = 100;
fovScene      = 10;

%% Adjust FOV of camera to match scene, no extra pixels needed.
camera = cameraSet(camera,'sensor fov',fovScene);

%% Change the scene so its wavelength samples matches the camera
wave = cameraGet(camera,'sensor','wave');
scene = sceneSet(scene,'wave',wave');

%% Change illuminant to D65
scene = sceneAdjustIlluminant(scene,'D65.mat');

%% Set scene FOV and mean luminance
scene = sceneSet(scene,'hfov',fovScene);
scene = sceneAdjustLuminance(scene,meanLuminance);

%% Find white point
whitept = sceneGet(scene,'illuminant xyz');
whitept = whitept/max(whitept);

%% Calculate camera results
[camera,xyzIdeal] = cameraCompute(camera,scene,'idealxyz');
xyzIdeal  = xyzIdeal / max(xyzIdeal(:));
[srgbIdeal, lrgbIdeal] = xyz2srgb(xyzIdeal);
[camera,lrgbresult] = cameraCompute(camera,'oi',lrgbIdeal);   % OI is already calculated

%% Crop border of image
% This ignores any errors around the edge of the image  (this is similar to
% L3imcrop but with a fixed width)
xyzIdeal = xyzIdeal(11:end-10, 11:end-10, :);
lrgbresult = lrgbresult(11:end-10, 11:end-10, :);

%% Convert lrgbresult to srgb and xyz
srgbresult = lrgb2srgb(ieClip(lrgbresult,0,1));
xyzresult = srgb2xyz(srgbresult);

figure
imagesc(srgbresult)
axis image

%% Convert to Lab
% xyzIdeal = srgb2xyz(srgbIdeal);
LabIdeal = ieXYZ2LAB(xyzIdeal,whitept);
Labim    = ieXYZ2LAB(xyzresult,whitept);

%% Moire pattern measurement

% L and ab for Ideal
gray_Ideal = LabIdeal(:,:,1);
% vcNewGraphWin; imagesc(gray_Ideal); axis image; % truesize
% title('gray Ideal image')



abIdeal=sqrt(LabIdeal(:,:,2).^2+LabIdeal(:,:,3).^2);
vcNewGraphWin; imagesc(abIdeal); axis image; % truesize
title('abIdeal image')



% R_B_Ideal=srgbIdeal(:,:,1)-srgbIdeal(:,:,3);
% vcNewGraphWin; imagesc(R_B_Ideal); axis image; % truesize
% title('(R-B) Ideal image')

% gray_im = Labim(:,:,1);
% vcNewGraphWin; imagesc(gray_im); axis image; % truesize
% title('gray image')

abim = sqrt(Labim(:,:,2).^2+Labim(:,:,3).^2);
vcNewGraphWin; imagesc(abim); axis image; % truesize
title('ab Image')

% R_B=Labim(:,:,1)-Labim(:,:,3);
% vcNewGraphWin; imagesc(R_B); axis image; % truesize
% title('(R-B) image')

%% Delta E
deltaEim = deltaEab(xyzIdeal,xyzresult,whitept);
% vcNewGraphWin; imagesc(deltaEim);
% axis image; % truesize
% title('Delta E (RGBx)')

delta_e=mean(deltaEim(:));

%% Cut Boundary       This seems to not be needed.
[R C] = size(gray_Ideal);
abIdeal=abIdeal(3:R-2,3:C-2,:);
abim=abim(3:R-2,3:C-2,:);
deltaEim=deltaEim(3:R-2,3:C-2,:);
% R_B_Ideal=R_B_Ideal(3:R-2,3:C-2,:);
% R_B_L3=R_B_L3(3:R-2,3:C-2,:);

%% Moire Examination
% Selecct one among diagonalline, horizontalline
% [data_abL3_acc, data_abL3_moire, moire_cpd_L3] = moire_experiment(abIdeal, abL3, 'horizontalline');

% [data_R_B_L3] = moire_R_B(R_B_Ideal, R_B_L3, 'horizontalline');
% [data_abIdeal_var, data_abL3_var, cpd] = moire_experiment_new(abIdeal, abL3, 'horizontalline');
[data_abIdeal_mean, data_ab_mean, cpd_mean] = moire_using_mean(abIdeal, abim, 'horizontalline');
% [data_abIdeal_mean_acc, data_abL3_mean_acc, cpd_acc] = moire_using_mean_acc(abIdeal, abL3, 'horizontalline');
% [data_abIdeal_vertical, data_abL3_vertical, cpd_vertical] = moire_using_vertical(abIdeal, abL3, 'horizontalline');

% draw_result



%% Binarized?
% % Binarization
% Binarized_Ideal_image = zeros(R, C);
% mean_th = mean(gray_Ideal(:));
% for i=1:R
%     for j=1:C
%         if(gray_Ideal(i,j)>mean_th)
%             Binarized_Ideal_image(i,j)=1;
%         else
%             Binarized_Ideal_image(i,j)=0;
%         end
%     end
% end
% Binarized_Ideal_image=Binarized_Ideal_image(3:R-2,3:C-2,:);
% [data_deltaE] = moire_deltaE(deltaEim, Binarized_Ideal_image, 'horizontalline');

%% Put data in metric structure that we want to keep
metric.data_abIdeal_mean = data_abIdeal_mean;
metric.data_abim_mean = data_ab_mean;
metric.cpd_mean = cpd_mean;