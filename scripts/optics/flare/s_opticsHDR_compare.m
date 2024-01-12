%% Calculate PSF/OTF using wvf that matches the OI
% Interpolation in isetcam matches the resolution (um/sample) of the default 
% PSF/OTF with the OI resolution. However, this process introduces minor 
% artifacts in the PSF, such as horizontal and vertical streaks, 
% with intensity levels 1e4 to 1e5 times lower than the PSF's peak. 
% While generally not problematic, these artifacts could be noticeable in 
% HDR scenes, particularly in night settings.
%
% A potential solution is to generate a high-resolution OTF in real-time, 
% but this approach is computationally intensive for large scenes. 
% As a temporary workaround, we precalculate the OTF at the OI's resolution 
% and configure the OI accordingly. 
% This method allows oiCompute to bypass the interpolation step.


% Zhenyi, 2023

%%
ieInit;
ieSessionSet('init clear',true);
close all

%% Create a scene

s_size = 1024;
flengthM = 4e-3;
fnumber = 2.2;
flengthMM = flengthM*1e3;

pupilMM = (flengthMM)/fnumber;

scene = sceneCreateHDR(s_size,17,0);

scene = sceneAdjustLuminance(scene,'peak',1e5);

scene = sceneSet(scene,'fov',30);
index = 1;

%% Loop comparing the three methods

fig_plot = figure; set(fig_plot, 'AutoResizeChildren', 'off');
for fnumber = 5:4:13
    oi = oiCreate('diffraction limited');

    oi = oiSet(oi,'optics focallength',flengthM); % only in meters
    oi = oiSet(oi,'optics fnumber',fnumber);

    % oi needs information from scene to figure out the proper resolution.
    oi = oiCompute(oi, scene);
    oi = oiCrop(oi,'border');
    % oiWindow(oi);

    oi = oiSet(oi, 'name','dl');
    ip = piRadiance2RGB(oi,'etime',1);

    rgb = ipGet(ip,'srgb');
    subplot(3,3,index);imshow(rgb);index = index+1;title(sprintf('DL-Fnumber:%d\n',fnumber));

    %% Compute with oiComputeFlare

    aperture = [];
    oi.optics.model = 'shiftinvariant';
    oi_flare = oiCompute(oi,scene,'aperture',aperture);
    oi_flare = oiSet(oi_flare, 'name','flare');
    oi_flare = oiCrop(oi_flare,'border');
    % oiWindow(oi_flare);

    % oi_wvf = oiSet(oi_wvf,'displaymode','hdr');
    ip_flare = piRadiance2RGB(oi_flare,'etime',1);
    rgb_flare = ipGet(ip_flare,'srgb');
    subplot(3,3,index);imshow(rgb_flare);index = index+1;title(sprintf('Flare-Fnumber:%d\n',fnumber));

    %% match wvf with OI, and compute with oicompute
    wvf = wvfCreate;
    wvf = wvfSet(wvf, 'focal length', flengthMM, 'mm');
    wvf = wvfSet(wvf, 'calc pupil diameter', flengthMM/fnumber);
    nPixels = oiGet(oi, 'size'); nPixels = nPixels(1);
    wvf = wvfSet(wvf, 'spatial samples', nPixels);
    psf_spacingMM = oiGet(oi,'sample spacing','mm');
    lambdaMM = 550*1e-6;
    pupil_spacingMM = lambdaMM * flengthMM / (psf_spacingMM(1) * nPixels);
    wvf = wvfSet(wvf,'field size mm', pupil_spacingMM * nPixels);
    wvf = wvfCompute(wvf);
    wvfSummarize(wvf);

    oi_wvf = oiCompute(wvf, scene);
    oi_wvf = oiSet(oi_wvf, 'name','wvf');
    % oiWindow(oi_wvf);
    oi_wvf = oiCrop(oi_wvf,'border');
    ip_wvf = piRadiance2RGB(oi_wvf,'etime',1);
    rgb_wvf = ipGet(ip_wvf,'srgb');
    subplot(3,3, index);imshow(rgb_wvf);index = index+1;title(sprintf('WVF-Fnumber:%d\n',fnumber));
end
