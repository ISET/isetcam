%% Modular ISETCam Sensor & Color Router Analysis Pipeline
% This script is a modular refactor of the original exploratory workflow.
% It preserves all functionality: scene formation, RGB sensor simulation,
% QE separation, patch extraction, color router comparison, and XYZ transforms.

ieInit;

%% -------------------- USER CONFIGURATION --------------------
config.fovDeg        = 24;
config.sceneLuminance= 100;
config.wavelengthNm  = 400:5:700;
config.pixelSizeM    = 0.5e-6;
config.sensorRows    = 640;
config.sensorCols    = 960;
config.shortExpScale = 1/4;

config.rgbBaseRows   = [550 551];
config.rgbRowOffsets= [0 -150 -300 -450];
config.rgbCols       = [32:96, 102:166, 172:236, 243:307, 320:380, 390:450];

config.routerBaseRows   = [250 251];
config.routerRowOffsets= [0 -76 -150 -226];
config.routerCols       = [16:48, 51:83, 86:118, 122:153, 160:190, 195:225];

%% -------------------- PIPELINE EXECUTION --------------------

sceneObj  = createMacbethScene(config);
oiObj     = createOpticsAndCompute(sceneObj);
sensorRGB = createAndConfigureRGBSensor(config);
sensorRGB = separateQEandFilters(sensorRGB, config.wavelengthNm);
sensorRGB = computeShortExposure(sensorRGB, oiObj, config.shortExpScale);

[rgbPatch, rgbPatches, hFig] = sampleRGBPatches(sensorRGB, config);

sensorRouter = createColorRouterSensor(sensorRGB, config, oiObj);
routerPatches = sampleRouterPatches(sensorRouter, config, hFig);

[xyzRGB, xyzRouter] = computeXYZTransforms(rgbPatches, routerPatches, sensorRGB, sensorRouter, config.wavelengthNm);

plotXYZComparison(xyzRGB, xyzRouter);

%% ===================== FUNCTION DEFINITIONS =====================

function sceneObj = createMacbethScene(cfg)
% Create and display a Macbeth chart scene at a specified luminance and FOV.
sceneObj = sceneCreate('macBeth');
sceneObj = sceneAdjustLuminance(sceneObj, cfg.sceneLuminance);
sceneObj = sceneSet(sceneObj, 'fov', cfg.fovDeg);
sceneWindow(sceneObj);
end

function oiObj = createOpticsAndCompute(sceneObj)
% Create diffraction-limited optics and compute the optical image.
oiObj = oiCreate();
oiObj = oiSet(oiObj, 'optics fnumber', 1.0);
oiObj = oiSet(oiObj, 'optics focal length', 1e-3);
oiObj = oiCompute(oiObj, sceneObj);
oiWindow(oiObj);
end

function sensorRGB = createAndConfigureRGBSensor(cfg)
% Create a Sony-based RGB Bayer sensor with physical sampling set by pixel size.
pixelObj = pixelCreate('default', cfg.wavelengthNm);
qeFile   = fullfile(isetRootPath,'data','sensor','sony','qe_IMX363_public.mat');
cfaPattern = [1 2; 2 3];

sensorRGB = sensorCreate('custom', pixelObj, cfaPattern, qeFile);
sensorRGB = sensorSet(sensorRGB, 'pixel size constant fill factor', cfg.pixelSizeM);
sensorRGB = sensorSet(sensorRGB, 'rows', cfg.sensorRows);
sensorRGB = sensorSet(sensorRGB, 'cols', cfg.sensorCols);
end

function sensorRGB = separateQEandFilters(sensorRGB, wave)
% Decompose combined QE into intrinsic CMOS QE and color filter spectra.
irFilt = sensorGet(sensorRGB, 'irfilter');
qeCombined = sensorGet(sensorRGB, 'spectral qe');

cmosQE = ieReadSpectra('sonyCMOSQE', wave);
cmosQE = 1.2 * cmosQE; % empirical scaling

nChan = size(qeCombined, 2);
cfSpectra = zeros(numel(wave), nChan);

den = irFilt .* cmosQE;
den(den == 0) = eps;

for cc = 1:nChan
    cfSpectra(:, cc) = qeCombined(:, cc) ./ den;
end

cfSpectra = max(min(cfSpectra, 1.5), 0);

sensorRGB = sensorSet(sensorRGB, 'pixel spectral qe', cmosQE);
sensorRGB = sensorSet(sensorRGB, 'filter spectra', cfSpectra);
end

function sensorRGB = computeShortExposure(sensorRGB, oiObj, scale)
% Compute sensor response with reduced exposure time.
sensorRGB = sensorSet(sensorRGB, 'auto exposure', true);
sensorRGB = sensorSet(sensorRGB, 'noiseflag', -2);
sensorRGB = sensorCompute(sensorRGB, oiObj);

baseExp   = sensorGet(sensorRGB, 'exp time');
sensorRGB = sensorSet(sensorRGB, 'exp time', baseExp * scale);
sensorRGB = sensorCompute(sensorRGB, oiObj);

ieFigure;
imagesc(sensorRGB.data.volts);
axis image; colormap(gray); colorbar;
title('Sensor Voltages (Short Exposure)');
end

function [rgbPatch, rgbPatches, hFig] = sampleRGBPatches(sensorRGB, cfg)
% Extract one RGB patch and a cloud of RGB samples from horizontal sensor lines.

offIdx   = 1;
rowsRGB  = cfg.rgbBaseRows + cfg.rgbRowOffsets(offIdx);

lineA = sensorGet(sensorRGB, 'hline electrons', rowsRGB(1));
lineB = sensorGet(sensorRGB, 'hline electrons', rowsRGB(2));

% First reference patch
patchCols = cfg.rgbCols(1):cfg.rgbCols(numel(32:96));
rgbPatch = [ ...
    lineB.data{1}(32:96).', ...
    lineA.data{2}(32:96).', ...
    lineA.data{3}(32:96).' ];

rgbPatches = [ ...
    lineB.data{1}(cfg.rgbCols).', ...
    lineA.data{2}(cfg.rgbCols).', ...
    lineA.data{3}(cfg.rgbCols).' ];

hFig = ieFigure;
subplot(1,2,1); hold on;
plot(lineB.data{1},'r'); plot(lineA.data{2},'g'); plot(lineA.data{3},'b');
hold off; grid on;
xlabel('Column'); ylabel('Electrons');
title(sprintf('RGB Rows %d and %d', rowsRGB(1), rowsRGB(2)));

ieFigure;
scatter3(rgbPatches(:,1), rgbPatches(:,2), rgbPatches(:,3), 12,'.');
axis equal; grid on;
xlabel('R'); ylabel('G'); zlabel('B');
title('RGB Patch Cloud');
end

function sensorRouter = createColorRouterSensor(sensorRGB, cfg, oiObj)
% Replace RGB CFA with single-layer color router spectra.
routerOE = ieReadSpectra('singleLayerColorRouter', cfg.wavelengthNm);

ieFigure;
plot(cfg.wavelengthNm, routerOE,'LineWidth',1.2);
grid on;
xlabel('Wavelength (nm)'); ylabel('Efficiency');
title('Single-Layer Color Router');

sensorRouter = sensorRGB;
sensorRouter = sensorSet(sensorRouter, 'filter spectra', routerOE);

pSize = sensorGet(sensorRGB, 'pixel size');
sensorRouter = sensorSet(sensorRouter, 'pixel size constant fill factor', pSize * 2);
sensorRouter = sensorSet(sensorRouter, 'rows', 320);
sensorRouter = sensorSet(sensorRouter, 'cols', 480);

sensorRouter = sensorCompute(sensorRouter, oiObj);

ieFigure;
imagesc(sensorRouter.data.volts);
axis image; colormap(gray); colorbar;
title('Router Sensor Voltages');
end

function routerPatches = sampleRouterPatches(sensorRouter, cfg, hFig)
% Sample horizontal router sensor lines and form RGB patch cloud.

offIdx = 1;
rowsRouter = cfg.routerBaseRows + cfg.routerRowOffsets(offIdx);

lineA = sensorGet(sensorRouter, 'hline electrons', rowsRouter(1));
lineB = sensorGet(sensorRouter, 'hline electrons', rowsRouter(2));

figure(hFig);
subplot(1,2,2); hold on;
plot(lineB.pos{1}, lineB.data{1}/4,'r');
plot(lineA.pos{2}, lineA.data{2}/4,'g');
plot(lineA.pos{3}, lineA.data{3}/4,'b');
hold off; grid on;
xlabel('Column'); ylabel('Electrons/4');
title(sprintf('Router Rows %d and %d', rowsRouter(1), rowsRouter(2)));

routerPatches = [ ...
    lineB.data{1}(cfg.routerCols).', ...
    lineA.data{2}(cfg.routerCols).', ...
    lineA.data{3}(cfg.routerCols).' ];
end

function [xyzRGB, xyzRouter] = computeXYZTransforms(rgbPatches, routerPatches, sensorRGB, sensorRouter, wave)
% Compute least-squares transforms from sensor spectra into CIE XYZ.

XYZ = ieReadSpectra('XYZEnergy', wave);
sonyCF   = sensorGet(sensorRGB,  'spectral qe');
routerCF = sensorGet(sensorRouter,'spectral qe');

T_rgb    = sonyCF   \ XYZ;
T_router = routerCF\ XYZ;

xyzRGB    = rgbPatches    * T_rgb;
xyzRouter = routerPatches* T_router / 4;
end

function plotXYZComparison(xyzRGB, xyzRouter)
% Visual comparison of XYZ clouds for RGB vs color router.
ieFigure;
scatter3(xyzRGB(:,1), xyzRGB(:,2), xyzRGB(:,3), 12,'r','.'); hold on;
scatter3(xyzRouter(:,1), xyzRouter(:,2), xyzRouter(:,3), 12,'b','.');
axis equal; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('RGB vs Router XYZ Patch Comparison');
end
