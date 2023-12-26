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


% Zhenyi, 2023

%%
ieInit;
clear all; close all
%%
s_size = 1280;
flengthM = 5e-3;
fnumber = 4;
pupilMM = (flengthM*1e3)/fnumber;

scene = sceneCreate('point array',s_size,s_size);
scene = sceneSet(scene,'fov',20);

oi = oiCreate('shift invariant');

oi = oiSet(oi,'optics focallength',flengthM);
oi = oiSet(oi,'optics fnumber',flengthM*1e3/pupilMM);

% oi needs information from scene to figure out the proper resolution.
oi = oiCompute(oi, scene);
oiWindow(oi);

oi = oiSet(oi, 'name','icam');
oi = oiSet(oi,'displaymode','hdr');
ip = piRadiance2RGB(oi,'etime',1/30);
ipWindow(ip)


%% Match wvf with OI
t = tic;

[wvf,wvf_scale] = wvfMatchOI(oi);

nsides = 5; % circular aperture
[aperture, params] = wvfAperture(wvf,'nsides',nsides,...
    'dot mean',50, 'dot sd',20, 'dot opacity',0.5,'dot radius',100,...
    'line mean',50, 'line sd', 20, 'line opacity',0.5,'linewidth',80);
tic;
wvf = wvfCompute(wvf,'aperture',aperture);
toc;
% Resample PSFs, so that we do not need to interpolate them in oiCompute.
for ww = 1:numel(wvf.psf)

    psf_ww = wvf.psf{ww};
    [rows, cols] = size(psf_ww);
    [X, Y] = meshgrid(-cols/2:cols/2-1, -rows/2:rows/2-1);
    resample_rows = rows/wvf_scale;
    resample_cols = cols/wvf_scale;
    % New grid for resampling
    [Xq, Yq] = meshgrid(-resample_cols/2:resample_cols/2-1, -resample_rows/2:resample_rows/2-1);

    psf_resampled = interp2(X, Y, psf_ww, Xq, Yq, 'cubic');

    psf_resampled = psf_resampled/sum(psf_resampled(:));
    
    wvf.psf{ww} = psf_resampled;
end

wvf.refSizeOfFieldMM = wvf.refSizeOfFieldMM/wvf_scale;
wvf.nSpatialSamples  = wvf.nSpatialSamples/wvf_scale;

oi_wvf = oiCompute(wvf,scene);
oi_wvf = oiSet(oi_wvf, 'name','icam');

oiWindow(oi_wvf);
oi_wvf = oiSet(oi_wvf,'displaymode','hdr');
ip_wvf = piRadiance2RGB(oi_wvf,'etime',1/30);
ipWindow(ip_wvf);

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