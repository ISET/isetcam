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
s_size = 1024;
scene = sceneCreate('point array',s_size,s_size/2);
scene = sceneSet(scene,'fov',10);

waveList = sceneGet(scene,'wave');

oi = oiCreate();

flengthM = 7e-3;
fnumber = 2;
pupilMM = (flengthM*1e3)/fnumber;

oi = oiSet(oi,'optics focallength',flengthM);
oi = oiSet(oi,'optics fnumber',flengthM*1e3/pupilMM);

% oi needs information from scene to figure out the proper resolution.
oi = oiCompute(oi, scene);

oi_fsupport = oiGet(oi,'fsupport');
fx = oi_fsupport(:,:,1); fy = oi_fsupport(:,:,2);

nX    = size(fx,1);      nY = size(fy,1);
nWave = length(waveList);

oiDelta  = oiGet(oi,'sample spacing','mm');

%% now create a WVF that can calcuate the OTF that matches the OI
t = tic;
optics = oiGet(oi,'optics');
wvf    = optics2wvf(optics);
wvf    = wvfSet(wvf,'wave',waveList);

% we should give a proper size for filed size to allow for the accurate
% representation of the diffraction effects and any aberrations.

psf_sample = oiDelta(1); % mm

focallengthMM = flengthM*1e3;
lambda = 550 * 1e-6; % mm
nPixels = nX;
pupil_sample = lambda * focallengthMM/(nPixels * psf_sample);

% according to ChatGPT, 3 to 4 times the aperture seems a good number
pupilPlanDiameterMM = pupilMM * 3;
scaleFactor = pupilPlanDiameterMM/ (nPixels * pupil_sample);

if scaleFactor > 1
    scaleFactor = ceil(scaleFactor);
    nPixels = scaleFactor*nPixels;
    fprintf('Scale the pupil plane by %d times to have a proper PSF calculation.\n',scaleFactor)
end

fieldSizeMM = nPixels * pupil_sample;

% not sure whether it matters
% wvf = wvfSet(wvf, 'sample interval domain','pupil'); 

wvf = wvfSet(wvf, 'spatial samples', nPixels);

wvf = wvfSet(wvf,'field size mm',fieldSizeMM, 550 );

wvf = wvfCompute(wvf);  

fprintf('COMPLETED: Wavefront Size: %d, takes %.2f seconds. \n',nPixels, toc(t));

psf_ss = wvfGet(wvf, 'psf spatial samples', 'um', 550);

psf_sample_interval = psf_ss(2)-psf_ss(1);


oi_sample_interval = oiGet(oi,'sample spacing','um'); 

fprintf('PSF sample interval is %f.2 um; \n OI sample interval is %f.2 um \n', psf_sample_interval/scaleFactor, oi_sample_interval(1));
%%
wvfPlot(wvf,'psf','unit','um','wave',550,'plot range',15);

figure;imagesc(wvf.psf{1})
%%







