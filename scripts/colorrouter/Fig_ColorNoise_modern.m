
%% Initialize ISET
ieInit;

%% Scene

fov = 4;
wave = 400:5:700;                       % wavelength sampling (nm)
scene  = sceneCreate('macBeth',64,wave);
scene = sceneAdjustLuminance(scene,100);	% cd/m2
scene  = sceneSet(scene,'fov',fov);			% deg
% sceneWindow(scene);

%% Optics

oi = oiCreate;
oi = oiSet(oi,'optics fnumber',2.8);
oi = oiSet(oi,'optics focal length',5e-3);	% m
oi = oiCompute(oi,scene,'crop',true);
% oiWindow(oi);

%% Rewritten sensor setup, QE separation, and short-exposure capture.

%---------------------------
% Configuration / spectral sampling
%---------------------------
pixelSize_um = 0.5;                     % pixel size in micrometers (µm)
pixel = pixelCreate('default', wave);   % create pixel model with given wave

%---------------------------
% Load filter/QE file and create sensor
%---------------------------
filterFile = fullfile(isetRootPath, 'data', 'sensor', 'sony', 'qe_IMX363_public.mat');

% Create a custom sensor using the pixel model and a 2x2 mosaic pattern
mosaicPattern = [1 2; 2 3];             % simple RGB Bayer-style mapping
sensorCFA = sensorCreate('custom', pixel, mosaicPattern, filterFile);

% Set physical size and array dimensions
sensorCFA = sensorSet(sensorCFA, 'pixel size constant fill factor', pixelSize_um * 1e-6); % µm->m
sensorCFA = sensorSetSizeToFOV(sensorCFA,4,oi);
% sensorCFA = sensorSet(sensorCFA,'fov',oiGet(oi,'fov'),oi);
% sensorCFA = sensorSet(sensorCFA, 'rows', 640);
% sensorCFA = sensorSet(sensorCFA, 'cols', 960);

%---------------------------
% Separate pixel (CMOS) QE from color filter spectra
%---------------------------
irFilter   = sensorGet(sensorCFA, 'irfilter');   % IR-cut filter spectrum
spectralQE = sensorGet(sensorCFA, 'spectral qe');% combined spectral QE (per channel)
wave_sensor = sensorGet(sensorCFA, 'wave');      % wavelengths used by sensor

% Ensure wavelengths match expected sampling; if not, resample or use sensor's
if ~isequal(wave_sensor, wave)
    wave = wave_sensor;
    pixel = pixelCreate('default', wave);
end

% Read intrinsic CMOS QE and apply a small empirical scaling
cmosQE = ieReadSpectra('sonyCMOSQE', wave);
cmosQE = 1.2 * cmosQE;   % scale CMOS QE by 20%

% Compute color filter spectra: spectralQE ≈ irFilter .* cmosQE .* colorFilter
numChannels = size(spectralQE, 2);
cf = zeros(length(wave), numChannels);  % preallocate
for ii = 1:numChannels
    % Protect against division by zero in case irFilter or cmosQE has zeros
    denom = irFilter .* cmosQE;
    zeroIdx = denom == 0;
    denom(zeroIdx) = eps;  % small number to avoid division by zero
    cf(:, ii) = spectralQE(:, ii) ./ denom;
end

% Optionally clip unrealistic values
cf(cf < 0) = 0;
cf(cf > 1.5) = 1.5;  % limit extreme values from noise/divisions

%---------------------------
% Update sensor with separated QE and filters
%---------------------------
sensorCFA = sensorSet(sensorCFA, 'pixel spectral qe', cmosQE); % intrinsic pixel QE
sensorCFA = sensorSet(sensorCFA, 'filter spectra', cf);       % color filter transmittances

%---------------------------
% Compute sensor response with short exposure
%---------------------------
if ~exist('oi', 'var') || isempty(oi)
    error('Optical image object ''oi'' is not found in the workspace. Create or load an oi before running.');
end

% Let the sensor pick an automatic exposure, then reduce it for a short exposure
sensorCFA = sensorSet(sensorCFA, 'auto exposure', true);
sensorCFA = sensorSet(sensorCFA, 'noiseflag', -2);   % set noise model (example)
sensorCFA = sensorCompute(sensorCFA, oi);            % compute once to get exposure time
expTime = sensorGet(sensorCFA, 'exp time');         % read computed exposure time

% Shorten exposure to 1/4 and recompute sensor voltages
sensorCFA = sensorSet(sensorCFA, 'exp time', expTime / 4);
sensorCFA = sensorCompute(sensorCFA, oi);
sensorWindow(sensorCFA);

% {
% For fov of 4.
cp = [
     4   583
   695   585
   695   118
     1   116];
%}

% cp = chartCornerpoints(sensorCFA,false);
% There is a problem with a rounding factor in this analysis.  So some
% sFactors don't work with   
sFactor = 0.34;   
[rectsCFA,mLocs,pSize] = chartRectangles(cp,4,6,sFactor);  % MCC parameters
% chartRectsDraw(sensorCFA,rectsCFA);
rgbCFApatches_raw = chartRectsData(sensorCFA,mLocs,pSize(1),true);

rgbCFApatches = chartExtractRGB(rgbCFApatches_raw);

% Combine all Nx3 matrices into one Mx3 matrix and plot
%{
 allDataCFA = vertcat(rgbCFApatches{:});    % M×3
 ieFigure;
 scatter3(allDataCFA(:,1), allDataCFA(:,2), allDataCFA(:,3), 8, 'b', '.');
 axis equal; grid on;
 xlabel('R'); ylabel('G'); zlabel('B');
 title('All patches combined');
%}

%% Sensor (Color router)

% Apply single-layer color router spectra to a copy of sensorCFA and visualize.
% Assumes `wave`, `sensorCFA`, and an optical image `oi` exist in the workspace.

% Read router optical-efficiency (OE) spectrum sampled at `wave`
router_oe = ieReadSpectra('singleLayerColorRouter', wave);

% Create a sensor copy and set the router spectra as its filter responses
sensor_router = sensorCFA;                         % copy base sensor
sensor_router = sensorSet(sensor_router, 'filter spectra', router_oe);

% Double the effective pixel size (keeping fill factor constant)
pSize = sensorGet(sensorCFA, 'pixel size');       % pixel size in meters
sensor_router = sensorSet(sensor_router, ...
    'pixel size constant fill factor', pSize * 2);

% Reduce resolution for faster computation / smaller sensor
sensor_router = sensorSet(sensor_router, 'rows', 320);
sensor_router = sensorSet(sensor_router, 'cols', 480);

% Compute sensor response (requires optical image `oi`)
if ~exist('oi', 'var') || isempty(oi)
    error('Optical image object ''oi'' not found. Create or load an oi before running.');
end
sensor_router = sensorCompute(sensor_router, oi);
sensorWindow(sensor_router);

% {
% For fov of 4.
cp_router = [
    65   276
   415   278
   415    46
    66   45];
%}

%% Plotting the 24 clouds together

% cp = chartCornerpoints(sensor_router,false);
% There is a problem with a rounding factor in this analysis.  So some
% sFactors don't work with   
sFactor = 0.34;   
[rectsCFA,mLocs,pSize] = chartRectangles(cp_router,4,6,sFactor);  % MCC parameters
% chartRectsDraw(sensorCFA,rectsCFA);
rgbRouterpatches_raw = chartRectsData(sensor_router,mLocs,pSize(1),true);

% Eliminate the NaNs
rgbRouterpatches = chartExtractRGB(rgbRouterpatches_raw);

% Account for the scale factor of the color router size
for ii=1:24
    rgbRouterpatches{ii} = rgbRouterpatches{ii}/4;
end

% Combine all Nx3 matrices into one Mx3 matrix and plot

ieFigure;
allDataRouter = vertcat(rgbRouterpatches{:});    % M×3
scatter3(allDataRouter(:,1), allDataRouter(:,2), allDataRouter(:,3), 8, 'r', '.');
hold on;

% Overlay the sensorCFA data
allDataCFA = vertcat(rgbCFApatches{:});    % M×3
scatter3(allDataCFA(:,1), allDataCFA(:,2), allDataCFA(:,3), 8, 'b', '.');

axis equal; grid on;
xlabel('R'); ylabel('G'); zlabel('B');
title('All patches combined');


%% The transforms into XYZ space

XYZ = ieReadSpectra('XYZEnergy',wave);
sonyCF = sensorGet(sensorCFA,'spectral qe'); % Sony color filters
routerCF = sensorGet(sensor_router,'spectral qe');

% XWdata_rgb * T = XWdata_XYZ
% T_cfa = inv(sonyCF'*sonyCF) * (sonyCF'*XYZ);
T_cfa = sonyCF \ XYZ;
T_router = routerCF \ XYZ;

%{
ieFigure([],'wide'); tiledlayout(2,2);
nexttile;
XYZ_pred = sonyCF*T_cfa;
plot(XYZ(:),XYZ_pred(:),'.');
identityLine; grid on;

nexttile
plot(wave,XYZ_pred,'k-',wave,XYZ,'b--');
grid on;

nexttile;
% T_router = inv(routerCF'*routerCF) * (routerCF'*XYZ);

XYZ_pred = routerCF*T_router;
plot(XYZ(:),XYZ_pred(:),'.');
identityLine; grid on;

nexttile
plot(wave,XYZ_pred,'k-',wave,XYZ,'b--');
grid on;
%}

%% Convert the rgb patches into xyz patches

allDataCFA_xyz = allDataCFA*T_cfa;
allDataRouter_xyz = allDataRouter*T_router;

ieFigure;
scatter3(allDataCFA_xyz(:,1), allDataCFA_xyz(:,2), allDataCFA_xyz(:,3), 12, 'b', '.');
hold on;
scatter3(allDataRouter_xyz(:,1), allDataRouter_xyz(:,2), allDataRouter_xyz(:,3), 12, 'r', '.');
axis equal

%% Calculate the precision of each patch

xyzRouterPatches = cell(24,1);
for ii=1:24
    xyzRouterPatches{ii} = rgbRouterpatches{ii}*T_router;
end

xyzCFAPatches = cell(24,1);
for ii=1:24
    xyzCFAPatches{ii} = rgbCFApatches{ii}*T_cfa;
end

% White patch without the NaNs
whiteXYZ = mean(xyzRouterPatches{4});

% For each patch, calculate the Lab values for each point. 
labRouterPatches = cell(24,1);
colorPrecisionRouter = zeros(24,1);
for ii=1:24
    labRouterPatches{ii} = ieXYZ2LAB(xyzRouterPatches{ii},double(whiteXYZ));
    colorPrecisionRouter(ii) = det(cov(labRouterPatches{ii}))^(1/3);
end

% For each patch, calculate the Lab values for each point. 
labCFAPatches = cell(24,1);
colorPrecisionCFA = zeros(24,1);
for ii=1:24
    labCFAPatches{ii} = ieXYZ2LAB(xyzCFAPatches{ii},double(whiteXYZ));
    colorPrecisionCFA(ii) = det(cov(labCFAPatches{ii}))^(1/3);
end

mean(colorPrecisionCFA)
mean(colorPrecisionRouter)


%% Convert to LAB using the white point

% ieXYZ2LAB or xyz2lab
% Compute the standard deviation

%% sRGB
%{
row = size(xyz_router_patches,1);
col = 1;
XW_router = XW2RGBFormat(xyz_router_patches,row,col);
sRGB_router = xyz2srgb(XW_router);
srgb_XW_router = RGB2XWFormat(sRGB_router);

row = size(xyz_rgb_patches,1);
col = 1;
XW_rgb = XW2RGBFormat(xyz_rgb_patches,row,col);
sRGB_rgb = xyz2srgb(XW_rgb);
srgb_XW_rgb = RGB2XWFormat(sRGB_rgb);

ieFigure;
scatter3(srgb_XW_rgb(:,1), srgb_XW_rgb(:,2), srgb_XW_rgb(:,3), 12, 'r', '.');
hold on;
scatter3(srgb_XW_router(:,1), srgb_XW_router(:,2), srgb_XW_router(:,3), 12, 'b', '.');
%}

%% color router - patch data
%{
sensor_router = sensorSet(sensor_router,'roi',[35,235,55,60]);
sensorGet(sensor_router,'roi rect')
%sensor_router = sensorSet(sensor_router,'roi',[35,235,2,2]);
router_area1 = sensorGet(sensor_router,'roi electrons');
%router_area1 = reshape(router_area1,3,61,56);
%router_area1 = permute(router_area1,[3,2,1]);
%figure(3); imagesc(router_area1)
mean(router_area1(:,1),'omitnan')
%}

%% Color router: 3-plane
%{
clear sensor_router_array
for ii=1:3
    sensor_router_array(ii) = sensorSet(sensor_router,'filter spectra',router_oe(:,ii));
    sensor_router_array(ii).cfa.pattern = 1;
end

%sensor_router_array = sensorCompute(sensor_router_array,oi);
%ieAddObject(sensor_router_array(1)); sensorWindow;

%}

%% Sensor (RGB filers) - line data

%{
% Clear and clarified version of the original code.
% Extract RGB horizontal line data from sensor, select column ranges,
% compute patch statistics, and visualize in 2D and 3D.

% Parameters: choose two sensor rows (example offsets)
base_rows = [550, 551];          % original row indices
row_offsets = [0, -150, -300, -450]; % possible offsets (choose one)

% Choosing offset index 1 is the white row
offset_index = 1;                % pick which offset to apply (1..4)
rows_rgb = base_rows + row_offsets(offset_index);  % final row indices

% Column groups used to sample patches across the line
cols_rgb = [32:96, 102:166, 172:236, 243:307, 320:380, 390:450];

% Read horizontal-line electron counts for the two selected rows.
% sensorCFA must exist in the workspace.
line1 = sensorGet(sensorCFA, 'hline electrons', rows_rgb(1));
line2 = sensorGet(sensorCFA, 'hline electrons', rows_rgb(2));

% Sanity check: expect three color channels in each line
nChan1 = numel(line1.data);
nChan2 = numel(line2.data);
if nChan1 < 3 || nChan2 < 3
    error('Expected at least 3 color channels in the horizontal line data.');
end

% Plot the three color channels for the second and first lines
hdl1 = ieFigure;
subplot(1,2,1);
hold on;
plot(1:length(line2.data{1}), line2.data{1}, 'r'); % red channel of line2
plot(1:length(line1.data{2}), line1.data{2}, 'g'); % green channel of line1
plot(1:length(line1.data{3}), line1.data{3}, 'b'); % blue channel of line1
hold off;
xlabel('Column index'); ylabel('Electrons');
% legend('Line2 - R', 'Line1 - G', 'Line1 - B');
title(sprintf('Rows %d (line1) and %d (line2)', rows_rgb(1), rows_rgb(2)));
axis tight; grid on;

% Compute standard deviations for the first patch region (columns 32:96)
patch_range = 32:96;
std_r = std(line2.data{1}(patch_range)); % red std from line2
std_g = std(line1.data{2}(patch_range)); % green std from line1
std_b = std(line1.data{3}(patch_range)); % blue std from line1;
rgb_line_std = [std_r, std_g, std_b];

% Assemble the first RGB patch (as vectors) and scatter in 3D
rgb_patch1 = [ line2.data{1}(patch_range).' , ...
               line1.data{2}(patch_range).' , ...
               line1.data{3}(patch_range).' ]; % Nx3 matrix
%}
%% Single patch

%{
ieFigure;
scatter3(rgb_patch1(:,1), rgb_patch1(:,2), rgb_patch1(:,3), 20, rgb_patch1/ max(rgb_patch1(:)), 'filled');
axis equal;
xlabel('R electrons'); ylabel('G electrons'); zlabel('B electrons');
title('3D scatter: patch columns 32:96');
axis equal
%}

%% A row of patches
%{
% Build RGB samples from the multiple column groups defined in cols_rgb
% cols_rgb is a concatenation of several contiguous ranges; sample those columns
numSamples = numel(cols_rgb);
rgb_patches = zeros(numSamples, 3); % rows: samples, cols: R,G,B
rgb_patches(:,1) = line2.data{1}(cols_rgb).'; % R
rgb_patches(:,2) = line1.data{2}(cols_rgb).'; % G
rgb_patches(:,3) = line1.data{3}(cols_rgb).'; % B

% 3D scatter of all sampled patches
ieFigure;
scatter3(rgb_patches(:,1), rgb_patches(:,2), rgb_patches(:,3), 10, '.');
axis equal;
xlabel('R electrons'); ylabel('G electrons'); zlabel('B electrons');
title('3D scatter: sampled column groups');

% Optional: report computed standard deviations
fprintf('Patch std (R,G,B) for columns %d:%d: [%.3f, %.3f, %.3f]\n', ...
    patch_range(1), patch_range(end), rgb_line_std(1), rgb_line_std(2), rgb_line_std(3));

%}

%%
%{
% Display the sensor voltages
ieFigure;
imagesc(sensor_router.data.volts);
axis image; colormap(gray); colorbar;
title('Sensor Voltages (with color router)');
%}

%% Sensor (Color router) - line data
%{
% Clearer version: select two sensor rows with configurable offset,
% read horizontal-line electron data from sensor_router, and plot RGB channels.
% Assumes sensor_router exists in the workspace.

% Base row indices and available offsets
base_rows = [250, 251];               % original row indices
row_offsets = [0, -76, -150, -226];   % allowed offsets
offset_choice = 1;                    % choose which offset to apply (1..numel(row_offsets))

% Compute final row indices
if offset_choice < 1 || offset_choice > numel(row_offsets)
    error('offset_choice must be between 1 and %d', numel(row_offsets));
end
rows_router = base_rows + row_offsets(offset_choice);

% Column groups used for sampling (kept for reference; not required by plot)
cols_router = [16:48, 51:83, 86:118, 122:153, 160:190, 195:225];

% Read horizontal-line electron counts for the two selected rows.
% Each line returns a struct with .pos (cell per channel) and .data (cell per channel).
line1 = sensorGet(sensor_router, 'hline electrons', rows_router(1));
line2 = sensorGet(sensor_router, 'hline electrons', rows_router(2));

% Basic sanity checks
if ~isfield(line1, 'data') || ~isfield(line2, 'data')
    error('Unexpected hline format returned by sensorGet.');
end
nCh = numel(line1.data);
if nCh < 3
    error('Expected at least 3 color channels in horizontal line data.');
end

% Plot the three color channels for the two lines in the existing figure handle hdl1.
% Scale the electron counts by 1/4 for visualization (as in original code).
figure(hdl1);
subplot(1,2,2);
hold on;
plot(line2.pos{1}, line2.data{1} / 4, 'r', ...   % Red from second row
     line1.pos{2}, line1.data{2} / 4, 'g', ...   % Green from first row
     line1.pos{3}, line1.data{3} / 4, 'b');      % Blue from first row
hold off;

grid on;
xlabel('Column index');
ylabel('Electrons / 4');
title(sprintf('Rows %d and %d (offset %d)', rows_router(1), rows_router(2), row_offsets(offset_choice)));
% legend('R (row2)', 'G (row1)', 'B (row1)', 'Location', 'best');
axis tight;
%}

%% Compute stats for  a single patch
%{
% router patches and compare RGB vs router in 3D.

% Assumes router_line1, router_line2, cols_router, rgb_patch1, and rgb_patches1 exist.

% Define patch column range (first patch: columns 16..48)
patchRange = 16:48;

% Compute standard deviation of electrons in the patch for R, G, B channels
std_r = std(line2.data{1}(patchRange)); % R from line2
std_g = std(line1.data{2}(patchRange)); % G from line1
std_b = std(line1.data{3}(patchRange)); % B from line1
router_line_std = [std_r, std_g, std_b];

% Assemble the first router RGB patch as an N×3 matrix
router_patch1 = [ line2.data{1}(patchRange).', ...
                  line1.data{2}(patchRange).', ...
                  line1.data{3}(patchRange).' ]; % columns: R, G, B
%}
% 3D scatter of the router patch (scale by 1/4 as in original code)
%{
ieFigure;
scatter3(router_patch1(:,1)/4, router_patch1(:,2)/4, router_patch1(:,3)/4, 36, 'b', 'filled');
xlabel('R (electrons /4)'); ylabel('G (electrons /4)'); zlabel('B (electrons /4)');
title('Router Patch (columns 16:48)'); grid on; axis equal;
%}

% Compare router patch with the previously computed RGB patch (rgb_patch1)
% Ensure rgb_patch1 exists and has compatible size
%{
if exist('rgb_patch1', 'var')
    ieFigure;
    scatter3(rgb_patch1(:,1), rgb_patch1(:,2), rgb_patch1(:,3), 20, 'r', 'filled');
    hold on;
    scatter3(router_patch1(:,1)/4, router_patch1(:,2)/4, router_patch1(:,3)/4, 20, 'b', 'filled');
    hold off;
    %legend('RGB patch', 'Router patch (scaled)', 'Location', 'best');
    xlabel('R'); ylabel('G'); zlabel('B'); title('RGB vs Router Patch Comparison'); grid on; axis equal;
else
    warning('rgb_patch1 is missing or size mismatch; skipping direct patch comparison plot.');
end
%}
%}

%% Sample multiple router patch points using cols_router (concatenated indices)
%{
router_patches1 = [ line2.data{1}(cols_router).', ...
                    line1.data{2}(cols_router).', ...
                    line1.data{3}(cols_router).' ]; % Mx3 matrix

% 3D scatter comparing many sampled patches from rgb_patches1 and router_patches1
ieFigure;
hold on;
if exist('rgb_patches', 'var')
    scatter3(rgb_patches(:,1), rgb_patches(:,2), rgb_patches(:,3), 12, 'r', '.');
else
    try
        rp = reshape(rgb_patches, [], 3);
        scatter3(rp(:,1), rp(:,2), rp(:,3), 12, 'r', '.');
    catch
        warning('rgb_patches not available in compatible shape; plotting only router samples.');
    end
end

% Plot router samples (scaled by 1/4)
scatter3(router_patches1(:,1)/4, router_patches1(:,2)/4, router_patches1(:,3)/4, 12, 'b', '.');
hold off;
xlabel('R'); ylabel('G'); zlabel('B');
% legend('RGB samples', 'Router samples (scaled)', 'Location', 'best');
title('Sampled Patch Clouds'); grid on; axis equal;
%}