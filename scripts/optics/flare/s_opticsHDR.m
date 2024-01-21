%% Calculate PSF/OTF using wvf that matches the OI
% Interpolation in isetcam matches the resolution (um/sample) of the default 
% PSF/OTF with the OI resolution. However, this process introduces minor 
% artifacts in the PSF, such as horizontal and vertical spiky lines, 
% with intensity levels 1e4 to 1e5 times lower than the PSF's peak. 
% While generally not problematic, these artifacts could be noticeable in 
% HDR scenes, particularly in night settings.
%
% A potential solution is to generate a high-resolution OTF in real-time, 
% but this approach is computationally intensive for large scenes. 
% As a temporary workaround, we precalculate the OTF at the OI's resolution 
% and configure the OI accordingly. 
% This method allows oiCompute to bypass the interpolation step.
%
% Zhenyi, 2023

%  Not running.  Maybe delete or debug
% 
return;

%%
ieInit;
ieSessionSet('init clear',true);
close all;
%%
s_size = 4000;
flengthM = 17e-3;
fnumber = 8;

pupilMM = (flengthM*1e3)/fnumber;

scene = sceneCreateHDR(s_size,17,1);

scene = sceneAdjustLuminance(scene,'peak',1e5);

scene = sceneSet(scene,'fov',20);
scene = sceneSet(scene,'distance', 1);

index = 1;
fig = figure;set(fig, 'AutoResizeChildren', 'off');
for fnumber = 3:5:13
    oi = oiCreate('diffraction limited');

    oi = oiSet(oi,'optics focallength',flengthM);
    oi = oiSet(oi,'optics fnumber',fnumber);
    % oi needs information from scene to figure out the proper resolution.
    oi = oiCompute(oi, scene);
    oi = oiCrop(oi,'border');
    % oiWindow(oi);

    oi = oiSet(oi, 'name','dl');
    % oi = oiSet(oi,'displaymode','hdr');
    ip = piRadiance2RGB(oi,'etime',1);

    rgb = ipGet(ip,'srgb');
    subplot(3,3,index);imshow(rgb);index = index+1;title(sprintf('DL-Fnumber:%d\n',fnumber));
    
    %% Match wvf with OI
    aperture = [];
    oi.optics.model = 'shiftinvariant';
    oi_wvf = oiCompute(oi,scene,'aperture',aperture,'pixelsize',2.0833e-6);
    oi_wvf = oiSet(oi_wvf, 'name','flare');
    oi_wvf = oiCrop(oi_wvf,'border');
    % oiWindow(oi_wvf);

    % oi_wvf = oiSet(oi_wvf,'displaymode','hdr');
    ip_wvf = piRadiance2RGB(oi_wvf,'etime',1,'pixel size',3); % um
    rgb_wvf = ipGet(ip_wvf,'srgb');
    subplot(3,3,index);imshow(rgb_wvf);index = index+1;title(sprintf('Flare-Fnumber:%d\n',fnumber));
    subplot(3,3, index);imagesc(abs(rgb(:,:,2)-rgb_wvf(:,:,2)));colormap jet; colorbar; index = index+1;title('difference');
    % assert(max2(abs(rgb(:,:,2)-rgb_wvf(:,:,2)))<0.1);
end
%% Modify aperture

% Compare with this: https://en.wikipedia.org/wiki/File:Comparison_aperture_diffraction_spikes.svg
nsides_list = [0, 4, 5, 6];

fig_2 = figure(2); set(fig_2, 'AutoResizeChildren', 'off');
for ii = 1:4
    nsides = nsides_list(ii); % circular aperture
    %
    wvf    = wvfCreate('spatial samples', 512);

    [aperture, params] = wvfAperture(wvf,'nsides',nsides,...
        'dot mean',0, 'dot sd',0, 'dot opacity',0.5,'dot radius',5,...
        'line mean',0, 'line sd', 0, 'line opacity',0.5,'linewidth',2);

    oi_wvf = oiCompute(oi,scene,'aperture',aperture);

    oi_wvf = oiSet(oi_wvf, 'name','flare');
    oi_wvf = oiCrop(oi_wvf,'border');
    ip_wvf = piRadiance2RGB(oi_wvf,'etime',1);
    rgb_wvf = ipGet(ip_wvf,'srgb');

    subplot(1, 4, ii);imshow(rgb_wvf);title(sprintf('Number of blades: %d\n',nsides));
end

%{
% Check some numbers
fprintf('COMPLETED: Wavefront Size: %d, takes %.2f seconds. \n',nPixels, toc(t));

psf_ss = wvfGet(wvf, 'psf spatial samples', 'um', 550);

psf_sample_interval = psf_ss(2)-psf_ss(1);

oi_sample_interval = oiGet(oi,'sample spacing','um'); 

fprintf('PSF sample interval is %f.2 um; \n OI sample interval is %f.2 um \n', psf_sample_interval*scaleFactor, oi_sample_interval(1));

figure;imagesc(wvf.psf{1});clim([1e-20 1e-7]);

wvf_fx = wvfGet(wvf, 'otf support', 'mm', 550);

fprintf('Freqency Extent: WVF: %.4f, OI: %.4f \n', wvf_fx(end)/scaleFactor, fx(end));
%}