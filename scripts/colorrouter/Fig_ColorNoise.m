
%% Initialize ISET

%{
 cd 'F:\Software\GitHub\iset'
 isetPath(pwd)
%}

%% Scene

fov = 24;
scene  = sceneCreate('macBeth');
%scene = sceneAdjustLuminance(scene,200);	% cd/m2
scene = sceneAdjustLuminance(scene,100);	% cd/m2
scene  = sceneSet(scene,'fov',fov);			% deg
ieAddObject(scene); sceneWindow;

%% Optics

oi = oiCreate;
oi = oiSet(oi,'optics fnumber',1.0);
% oi = oiSet(oi,'optics offaxis','cos4th');
oi = oiSet(oi,'optics focal length',1e-3);	% m
oi = oiCompute(oi,scene);
ieAddObject(oi); oiWindow;

%% Sensor (RGB filters)

pixelSize = 0.5;
pixel = pixelCreate('default',400:5:700);

cd 'F:\Software\GitHub\isetcam-dev-color-router'
filterFile = fullfile(isetRootPath,'data','sensor','sony','qe_IMX363_public.mat');

cd 'F:\Software\GitHub\iset'
sensorRGB = sensorCreate('custom',pixel,[1,2;2,3],filterFile);
sensorRGB = sensorSet(sensorRGB,'pixel size constant fill factor', pixelSize*1e-6);
sensorRGB = sensorSet(sensorRGB,'rows',640);
sensorRGB = sensorSet(sensorRGB,'cols',960);
%sensorGet(sensorRGB,'pixel size')

irFilter = sensorGet(sensorRGB,'irfilter');
spectralQE = sensorGet(sensorRGB,'spectral qe');
wave = sensorGet(sensorRGB,'wave');

cd 'F:\Software\GitHub\isetcam-dev-color-router\scripts\colorrouter'
cmosQE = ieReadSpectra('sonyCMOSQE',wave); cmosQE = (1.2*cmosQE);
for ii = 1:3
    cf(:,ii) = spectralQE(:,ii) ./ (irFilter .* cmosQE);
end
%plot(wave,cf);
cd 'F:\Software\GitHub\iset'
sensorRGB = sensorSet(sensorRGB,'pixel spectral qe',cmosQE);
sensorRGB = sensorSet(sensorRGB,'filter spectra',cf);

% Short exposure
sensorRGB = sensorSet(sensorRGB,'auto exposure',true);
%sensorRGB = sensorSet(sensorRGB,'noiseflag',-2);
sensorRGB = sensorCompute(sensorRGB,oi);
expTime = sensorGet(sensorRGB,'exp time')
sensorRGB = sensorSet(sensorRGB,'exp time',expTime/4);
sensorRGB = sensorCompute(sensorRGB,oi);

figure(1); imagesc(sensorRGB.data.volts)

%% Sensor (RGB filers) - line data

rows_rgb = [550,551];
rows_rgb = [550,551]-150;
rows_rgb = [550,551]-300;
rows_rgb = [550,551]-450;
cols_rgb = [32:96,102:166,172:236,243:307,320:380,390:450];

rgb_line1 = sensorGet(sensorRGB,'hline electrons',rows_rgb(1,1));
rgb_line2 = sensorGet(sensorRGB,'hline electrons',rows_rgb(1,2));

% figure(2); 
hdl1 = vcNewGraphWin;
subplot(1,2,1);
plot(rgb_line2.pos{1},rgb_line2.data{1},'r',rgb_line1.pos{2},rgb_line1.data{2},'g', ...
    rgb_line1.pos{3},rgb_line1.data{3},'b')
plot(1:480,rgb_line2.data{1},'r',1:480,rgb_line1.data{2},'g', ...
    1:480,rgb_line1.data{3},'b')

% First patch
rgb_line_std = [std(rgb_line2.data{1}(32:96)), std(rgb_line1.data{2}(32:96)), ...
    std(rgb_line1.data{3}(32:96))]

rgb_patch1(:,:,1) = rgb_line2.data{1}(32:96);
rgb_patch1(:,:,2) = rgb_line1.data{2}(32:96);
rgb_patch1(:,:,3) = rgb_line1.data{3}(32:96);
figure(4); scatter3(rgb_patch1(:,:,1),rgb_patch1(:,:,2),rgb_patch1(:,:,3))
axis equal

clear rgb_patches1
rgb_patches1(:,:,1) = rgb_line2.data{1}(cols_rgb(1,:));
rgb_patches1(:,:,2) = rgb_line1.data{2}(cols_rgb(1,:));
rgb_patches1(:,:,3) = rgb_line1.data{3}(cols_rgb(1,:));
figure(4); scatter3(rgb_patches1(:,:,1),rgb_patches1(:,:,2),rgb_patches1(:,:,3),'.')
axis equal


%% Sensor (Color router)

cd 'F:\Software\GitHub\isetcam-dev-color-router\scripts\colorrouter'
router_oe = ieReadSpectra('singleLayerColorRouter',wave);
% load('routerdata','OE','wavelength');
vcNewGraphWin; plot(wave,router_oe); grid on;
xlabel('Wavelength (nm)'); ylabel('Efficiency');

cd 'F:\Software\GitHub\iset'
sensor_router = sensorRGB;
sensor_router = sensorSet(sensor_router,'filter spectra',router_oe);
%figure(3); sensorPlot(sensor_router,'spectral qe');

pSize = sensorGet(sensorRGB,'pixel size')
sensor_router = sensorSet(sensor_router,'pixel size constant fill factor', pSize*2);
%sensorGet(sensor_router,'pixel size')
sensor_router = sensorSet(sensor_router,'rows',320);
sensor_router = sensorSet(sensor_router,'cols',480);

sensor_router = sensorCompute(sensor_router,oi);
vcNewGraphWin;
imagesc(sensor_router.data.volts)

%% Sensor (Color router) - line data

rows_router = [250,251];
rows_router = [250,251]-76;
rows_router = [250,251]-150;
rows_router = [250,251]-226;
cols_router = [16:48,51:83,86:118,122:153,160:190,195:225];

router_line1 = sensorGet(sensor_router,'hline electrons',rows_router(1,1));
router_line2 = sensorGet(sensor_router,'hline electrons',rows_router(1,2));

figure(hdl1);
subplot(1,2,2);
plot(router_line2.pos{1},router_line2.data{1}/4,'r', ...
    router_line1.pos{2},router_line1.data{2}/4,'g', ...
    router_line1.pos{3},router_line1.data{3}/4,'b')
%plot(1:240,router_line2.data{1},'r',1:240,router_line1.data{2},'g', ...
%    1:240,router_line1.data{3},'b')
grid on;

%%
router_line_std = [std(router_line2.data{1}(16:48)), std(router_line1.data{2}(16:48)), ...
    std(router_line1.data{3}(16:48))]

router_patch1(:,:,1) = router_line2.data{1}(16:48);
router_patch1(:,:,2) = router_line1.data{2}(16:48);
router_patch1(:,:,3) = router_line1.data{3}(16:48);
vcNewGraphWin;
scatter3(router_patch1(:,:,1)/4,router_patch1(:,:,2)/4,router_patch1(:,:,3)/4)

vcNewGraphWin;
scatter3(rgb_patch1(:,:,1),rgb_patch1(:,:,2),rgb_patch1(:,:,3),'r'); hold on
scatter3(router_patch1(:,:,1)/4,router_patch1(:,:,2)/4,router_patch1(:,:,3)/4,'b')

clear router_patches1
router_patches1(:,:,1) = router_line2.data{1}(cols_router(1,:));
router_patches1(:,:,2) = router_line1.data{2}(cols_router(1,:));
router_patches1(:,:,3) = router_line1.data{3}(cols_router(1,:));
%figure(6); scatter3(router_patches1(:,:,1),router_patches1(:,:,2),router_patches1(:,:,3),'.')

vcNewGraphWin;
scatter3(rgb_patches1(:,:,1),rgb_patches1(:,:,2),rgb_patches1(:,:,3),'r.'); hold on
scatter3(router_patches1(:,:,1)/4,router_patches1(:,:,2)/4,router_patches1(:,:,3)/4,'b.')


%% color router - patch data

sensor_router = sensorSet(sensor_router,'roi',[35,235,55,60]);
sensorGet(sensor_router,'roi rect')
%sensor_router = sensorSet(sensor_router,'roi',[35,235,2,2]);
router_area1 = sensorGet(sensor_router,'roi electrons');
%router_area1 = reshape(router_area1,3,61,56);
%router_area1 = permute(router_area1,[3,2,1]);
%figure(3); imagesc(router_area1)
mean(router_area1(:,1),'omitnan')

%% Color router: 3-plane

clear sensor_router_array
for ii=1:3
    sensor_router_array(ii) = sensorSet(sensor_router,'filter spectra',router_oe(:,ii));
    sensor_router_array(ii).cfa.pattern = 1;
end

%sensor_router_array = sensorCompute(sensor_router_array,oi);
%ieAddObject(sensor_router_array(1)); sensorWindow;

