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

fprintf('PSF sample spacing is %.f um \n', psf_sample*1e3);

focallengthMM = oiGet(oi,'focal length','mm');

ref_wave = 400;
lambda = ref_wave * 1e-6; % mm

if nX > nY
    nPixels = nX;
else
    nPixels = nY;
end

% Ref: https://hal.science/hal-01741583/document
% Equation 25:
% cutoffFrequency = 1/(lambda * fnumber)
% psf_sample = 1/cutoffFreqency
% pupil_plane = pupil_sample*nPixels;
% fnumber = focallength/ (pupil_sample*nPixels)
% cutoffFrequency = pupil_plane/(focallength*lambda)
% cutoffFrequency increases as the size of pupil_plane increase
pupil_sample = lambda * focallengthMM/ (psf_sample * nPixels);

apertureDiameter = nPixels * pupil_sample;

scaleFactor = wvf.calcpupilMM * 6/ apertureDiameter;

if scaleFactor>1
    scale = round(scaleFactor*nPixels)/(nPixels);
else
    scale = 1;
end

fprintf('Scale the pupil plane by %.4f times to have a proper PSF calculation.\n',scale);

apertureDiameter_scaled = apertureDiameter*scale; % pupil_sample is smaller by scaleFactor times
nPixels_scaled = nPixels*scale;

fprintf('PupilDiamter: %.4f, Aperture: %.4f, number of samples: %d \n', ...
    wvf.calcpupilMM, apertureDiameter_scaled, nPixels_scaled);

wvf = wvfSet(wvf, 'spatial samples', nPixels_scaled, 'wave', ref_wave);

wvf = wvfSet(wvf,'field size mm',apertureDiameter_scaled);

if isempty(aperture), aperture =[]; end

tic;
wvf = wvfCompute(wvf,'aperture',aperture);
toc;

if scale>1
    % Assuming psf is your Point Spread Function matrix
    sigma_x = sqrt(scale); % Standard deviation for Gaussian filter
    sigma_y = sqrt(scale);
    filterSize_x = ceil(6 * sigma_x);
    filterSize_y = ceil(6 * sigma_y);
    % lowPassFilter = fspecial('gaussian', round(filterSize), sigma);
    filterX = fspecial('gaussian', [1, filterSize_x], sigma_x);
    filterY = fspecial('gaussian', [filterSize_y, 1], sigma_y);

    % combine the filter
    combinedFilter = conv2(filterY, filterX);

    % Resample PSFs, so that we do not need to interpolate them in oiCompute.
    for ww = 1:numel(wvf.psf)

        psf_ww = wvf.psf{ww};
        psf_filtered = imfilter(psf_ww, combinedFilter, 'conv');

        psf_resampled = imresize(psf_filtered, [nX, nY], 'bicubic','Antialiasing',true);
        psf_resampled = psf_resampled/sum(psf_resampled(:));
        wvf.psf{ww}  = psf_resampled;
    end
end

wvf.refSizeOfFieldMM = apertureDiameter;
wvf.nSpatialSamples  = nPixels;


end