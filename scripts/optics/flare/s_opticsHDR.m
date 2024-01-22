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
% return;

%%
ieInit;
ieSessionSet('init clear',true);
close all;

%%
s_size = 1000;
flengthM = 4e-3;
fnumber = 8;

pupilMM = (flengthM*1e3)/fnumber;

scene = sceneCreateHDR(s_size,17,1);

scene = sceneAdjustLuminance(scene,'peak',1e5);

scene = sceneSet(scene,'fov',10);
scene = sceneSet(scene,'distance', 1);

index = 1;
fig = figure;set(fig, 'AutoResizeChildren', 'off');
for fnumber = 3:5:13
    % DL 
    oi = oiCreate('diffraction limited');
    oi = oiSet(oi,'optics focallength',flengthM);
    oi = oiSet(oi,'optics fnumber',fnumber);
    % oi needs information from scene to figure out the proper resolution.
    oi = oiCompute(oi, scene);
    oi = oiCrop(oi,'border');
   
    % SI
    aperture = [];
    oi = oiSet(oi,'optics model','shift invariant');
    oi_wvf = oiCompute(oi,scene,'aperture',aperture);
    oi_wvf = oiSet(oi_wvf, 'name','flare');
    oi_wvf = oiCrop(oi_wvf,'border');
    %
    if exist('piRootPath.m','file')
        % If iset3d exist, use piRadiance2RGB
        ip = piRadiance2RGB(oi,'etime',1);
        rgb = ipGet(ip,'srgb');
        ip_wvf = piRadiance2RGB(oi_wvf,'etime',1);
        rgb_wvf = ipGet(ip_wvf,'srgb');

        subplot(3,3,index);imshow(rgb);index = index+1;title(sprintf('DL-Fnumber:%d\n',fnumber));
        subplot(3,3,index);imshow(rgb_wvf);index = index+1;title(sprintf('Flare-Fnumber:%d\n',fnumber));
        subplot(3,3, index);imagesc(abs(rgb(:,:,2)-rgb_wvf(:,:,2)));colormap jet; colorbar; index = index+1;title('difference');
    end

    assert(mean2(oi_wvf.data.photons(:,:,15))/mean2(oi.data.photons(:,:,15))-1 < 0.0001);
end

%% Change the shape of the aperture
if exist('piRootPath.m','file')
    % Compare with this: https://en.wikipedia.org/wiki/File:Comparison_aperture_diffraction_spikes.svg
    nsides_list = [0, 4, 5, 6];

    fig_2 = figure(2); set(fig_2, 'AutoResizeChildren', 'off');
    for ii = 1:4

        nsides = nsides_list(ii); 
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
end