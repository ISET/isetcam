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

scene = sceneCreateHDR(s_size,20, 0); % (size, numberOfPatches, Background)

scene = sceneAdjustLuminance(scene,'peak',100000);

scene = sceneSet(scene,'fov',30);
index = 1;

%% Loop comparing the three methods

fig_plot = figure;set(fig_plot, 'AutoResizeChildren', 'off');
for fnumber = 3:5:13
    oi = oiCreate('diffraction limited');

    oi = oiSet(oi,'optics focallength',flengthM);
    oi = oiSet(oi,'optics fnumber',fnumber);

    % oi needs information from scene to figure out the proper resolution.
    oi = oiCompute(oi, scene);
    oi = oiCrop(oi,'border');
    % oiWindow(oi);

    oi = oiSet(oi, 'name','dl');
    ip = piRadiance2RGB(oi,'etime',1);

    rgb = ipGet(ip,'srgb');
    subplot(3,3,index);imshow(rgb);index = index+1;title(sprintf('DL-Fnumber:%d\n',fnumber));

    oi.optics.model = 'shiftinvariant';
    %% Compute with oiComputeFlare

    aperture = [];
    oi_flare = oiComputeFlare2(oi,scene,'aperture',aperture);
    oi_flare = oiSet(oi_flare, 'name','flare');
    oi_flare = oiCrop(oi_flare,'border');
    % oiWindow(oi_wvf);

    % oi_wvf = oiSet(oi_wvf,'displaymode','hdr');
    ip_flare = piRadiance2RGB(oi_flare,'etime',1);
    rgb_flare = ipGet(ip_flare,'srgb');
    subplot(3,3,index);imshow(rgb);index = index+1;title(sprintf('Flare-Fnumber:%d\n',fnumber));

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

    oi = oiCompute(wvf, scene);
    oi = oiSet(oi, 'name','flare');
    % oiWindow(oi);
    oi = oiCrop(oi,'border');
    ip = piRadiance2RGB(oi,'etime',1);
    rgb = ipGet(ip,'srgb');
    subplot(3,3, index);imshow(rgb);index = index+1;title(sprintf('WVF-Fnumber:%d\n',fnumber));
end

%% Let's just compare the wvf methods at fnumber =3

%% THe flare good, working part.
%{
flengthM = 4e-3;
flengthMM = flengthM*1e3;

fnumber = 3;

%{
% This doesn't run with flare because dlmtf is ...
oi = oiCreate('diffraction limited');
oi = oiSet(oi,'name','diffraction');
oi = oiSet(oi,'optics focallength',flengthM);
oi = oiSet(oi,'optics fnumber',fnumber);
% psfdata = oiGet(oi,'optics psf data',550);
% ieNewGraphWin; mesh(psf.xy(:,:,1),psf.xy(:,:,2),psf.psf);
%}

%{
oi = oiCreate('shift invariant');
oi = oiSet(oi,'name','SI');
%}

oi = oiSet(oi,'optics focallength',flengthM);
oi = oiSet(oi,'optics fnumber',fnumber);
[oi_flare,~,psf, psfSupport] = oiComputeFlare(oi,scene,'aperture',aperture);
% oiWindow(oi_flare);
ieNewGraphWin; mesh(psfSupport(:,:,1),psfSupport(:,:,2),squeeze(psf(:,:,15)));
set(gca,'xlim',[-5 5],'ylim',[-5 5]);

% The bad wvf part
wvf = wvfCreate('wave',400:10:700);
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
psf2 = wvfGet(wvf,'psf',550);
supp2 = wvfGet(wvf,'spatial support','um');

% getMiddleMatrix(psf2,[50 50])
ieNewGraphWin; mesh(supp2,supp2,psf2);
set(gca,'xlim',[-5 5],'ylim',[-5 5]);

oi = oiCompute(wvf, scene);
oi = oiSet(oi,'name','WVF');
oiWindow(oi);
%}
