function wvf = wvfComputeFromOI(oi, aperture)
% Match otf support of wvf with the optical image, and compute the wvf
%
% Syntax:
%   wvf = wvfMatchOI(oi)
%
% Description:
%    
%    Before calling this function, compute the optical image with a scene.
%    This function matches the otf support of wvf with the f support for
%    the input optical image
%
%
% Inputs:
%    oi - An optical image computed from oiCompute.
%
% Outputs:
%    wvf - A wavefront parameters structure (without a computed PF and PSF)
%
% See also
%   
%    
%

% Examples:
%{
wvf = wvfCreate;
wvf = wvfCompute(wvf);
optics = wvf2optics(wvf);
%}

oi_fsupport = oiGet(oi,'fsupport','mm');
fx = oi_fsupport(:,:,1); fy = oi_fsupport(:,:,2);

nX    = size(fx,1);      nY = size(fy,1);

optics = oiGet(oi,'optics');
wvf    = optics2wvf(optics);

% we should give a proper size for filed size to allow for the accurate
% representation of the diffraction effects and any aberrations.

oiDelta  = oiGet(oi,'sample spacing','mm');
psf_sample = oiDelta(1); % mm


focallengthMM = oiGet(oi,'focal length','mm');

ref_wave = 550;
lambda = ref_wave * 1e-6; % mm

if nX > nY
    nPixels = nX;
else
    nPixels = nY;
end

% Sample width on pupil plane is connected to the sample width on PSF
% plane through Fourier Transform. A narrawer sample on pupile plane means
% higher freqency, thus wider space on PSF plane.

pupil_sample = lambda * focallengthMM/ (psf_sample * nPixels);

apertureDiameter = nPixels * pupil_sample;
% according to ChatGPT, 2 to 4 times the aperture seems a good number
scaleFactor = wvf.calcpupilMM * 3/ apertureDiameter;

if scaleFactor > 1
    scaleFactor = ceil(scaleFactor);
    % nPixels = scaleFactor*nPixels;
    fprintf('Scale the pupil plane by %d times to have a proper PSF calculation.\n',scaleFactor);
else
    scaleFactor = 1;
    fprintf('Pupil plane size unchanged.\n');
end

apertureDiameter_scaled = scaleFactor * apertureDiameter; % pupil_sample is smaller by scaleFactor times
nPixels_scaled = scaleFactor * nPixels;
fprintf('Aperture: %.4f, number of samples: %d \n', apertureDiameter_scaled, nPixels_scaled);
% nPixels     = scaleFactor *nPixels;

% not sure whether it matters
% wvf = wvfSet(wvf, 'sample interval domain','pupil');

wvf = wvfSet(wvf, 'spatial samples', nPixels_scaled);

wvf = wvfSet(wvf,'field size mm',apertureDiameter_scaled);

if isempty(aperture), aperture =[]; end

tic;
wvf = wvfCompute(wvf,'aperture',aperture);
toc;

% Resample PSFs, so that we do not need to interpolate them in oiCompute.
for ww = 1:numel(wvf.psf)

    psf_ww = wvf.psf{ww};
    [rows, cols] = size(psf_ww);
    [X, Y] = meshgrid(-cols/2:cols/2-1, -rows/2:rows/2-1);

    % New grid for resampling
    [Xq, Yq] = meshgrid(-nX/2:nX/2-1, -nY/2:nY/2-1);

    psf_resampled = interp2(X, Y, psf_ww, Xq, Yq, 'cubic');

    psf_resampled = psf_resampled/sum(psf_resampled(:));
    
    wvf.psf{ww} = psf_resampled;
end

wvf.refSizeOfFieldMM = wvf.refSizeOfFieldMM/scaleFactor;
wvf.nSpatialSamples  = wvf.nSpatialSamples/scaleFactor;


end