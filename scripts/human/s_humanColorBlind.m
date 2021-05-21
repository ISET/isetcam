%% s_HumanColorBlind
%
% Render images using the Brettell, Vienot, Mollon 1997
% method for showing appearance to the color blind.
%
% The algorithm converts XYZ values and a white XYZ into LMS values that
% can be shown as color image.
%
% (c) ImagEval 2012

%% Create an image and get the XYZ of the image and white

scene    = sceneCreate;
imgXYZ   = sceneGet(scene,'xyz');
whiteXYZ = sceneGet(scene,'illuminant xyz');
vcAddAndSelectObject(scene); sceneWindow

%%  Convert to color blind appearance and then image as srgb

% Show color images in a window
vcNewGraphWin;
for cbType = 1:3
    lms =  xyz2lms(imgXYZ, cbType, whiteXYZ);
    cbXYZ = imageLinearTransform(lms, colorTransformMatrix('lms2xyz'));
    subplot(3,1,cbType), imagesc(xyz2srgb(cbXYZ)); axis image; axis off
end

%%
% To visualize where the values are in 3-space do this In general for the
% Brettell algorithm, the data are in a bi-plane, not a single plane.  In
% this case, the biplane is onlyk visible for the tritan data, not the
% protan or deutan data.
vcNewGraphWin;
for cbType = 1:3
    lms =  xyz2lms(imgXYZ, cbType, whiteXYZ);
    cbXYZ = imageLinearTransform(lms, colorTransformMatrix('lms2xyz'));
    tmp = RGB2XWFormat(cbXYZ);
    subplot(3,1,cbType), plot3(tmp(:,1),tmp(:,2),tmp(:,3),'.'); grid on
end

%% Change the scene illumination

scene = sceneFromFile('StuffedAnimals_tungsten-hdrs.mat','multispectral');
imgXYZ   = sceneGet(scene,'xyz');
whiteXYZ = sceneGet(scene,'illuminant xyz');
% vcAddAndSelectObject(scene); sceneWindow

% Show color images in a window
vcNewGraphWin;
for cbType = 1:3
    lms =  xyz2lms(imgXYZ, cbType, whiteXYZ);
    cbXYZ = imageLinearTransform(lms, colorTransformMatrix('lms2xyz'));
    subplot(3,1,cbType), imagesc(xyz2srgb(cbXYZ)); axis image; axis off
end

%%

sFiles = cell(1,4);
sFiles{1} = which('MunsellSamples_Vhrel.mat');
sFiles{2} = which('Food_Vhrel.mat');
sFiles{3} = which('DupontPaintChip_Vhrel.mat');
sFiles{4} = which('HyspexSkinReflectance.mat');
%{
   sFiles{1} = fullfile(isetRootPath,'data','surfaces','reflectances','MunsellSamples_Vhrel.mat');
   sFiles{2} = fullfile(isetRootPath,'data','surfaces','reflectances','Food_Vhrel.mat');
   sFiles{3} = fullfile(isetRootPath,'data','surfaces','reflectances','DupontPaintChip_Vhrel.mat');
   sFiles{4} = fullfile(isetRootPath,'data','surfaces','reflectances','HyspexSkinReflectance.mat');
%}
sSamples = [12,12,25,25]*5; nSamples = sum(sSamples);
pSize = 24;

[scene, samples] = sceneReflectanceChart(sFiles,sSamples,pSize);
scene = sceneAdjustLuminance(scene,100);
vcAddAndSelectObject(scene); sceneWindow;

imgXYZ   = sceneGet(scene,'xyz');
whiteXYZ = sceneGet(scene,'illuminant xyz');

vcNewGraphWin;
for cbType = 1:3
    lms =  xyz2lms(imgXYZ, cbType, whiteXYZ);
    cbXYZ = imageLinearTransform(lms, colorTransformMatrix('lms2xyz'));
    subplot(3,1,cbType), imagesc(xyz2srgb(cbXYZ)); axis image; axis off
end

%% End