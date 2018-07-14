function err = psf2zcoeff(zcoeffs,psfTarget,pupilSizeMM, pupilPlaneSizeMM, thisWaveUM, nPixels)
% Error function for estimationg Zernike Coeffs from a psf
%
% Syntax
%   This function is called as part of an fminsearch procedure.  See the
%   script s_opticsPSF2Zcoeffs for the main example
%
%  f = @(x) psf2zcoeff(x,psfTarget,pupilSizeMM,pupilPlaneSizeMM,thisWaveUM, nPixels);
%
% Description
%  Given a spread function (psfTarget), we would like to estimate the
%  Zernike coefficients.  This allows us to calculate the pupil function
%  and wavefront aberrations. This function computes the RMS error between
%  the psfTarget for a set of Zernike coefficients.  We use this function
%  as part of an fminsearch to do the estimation in s_opticsPSF2Zcoeffs
%
% Inputs:
%   zcoeffs - The Zernike coefficients.  There should be at least 5!
%        zcoeffs = wvfGet(wvf,'zcoeffs');
%   thisWaveNM -       wvfGet(wvf,'wave');
%   pupilPlaneSizeMM - wvfGet(wvf,'pupil plane size','mm',thisWaveNM);
%   thisWaveUM       - waveNM(ii)/1000;
%   nPixels          - nPixels = wvfGet(wvf,'spatial samples');
%   pupilSizeMM      - pupilSizeMM = wvfGet(wvf,'pupil size','mm');
%
% BW, Vistasoft Team, 2018
%
% See also
%   s_opticsPSF2Zcoeffs, wvfCreate, wvfSet

% Examples:
%{
% BW should shorten this example!  It is the main code in the
% s_opticsPSF2Zcoeffs.m script

wvf = wvfCreate('wave',500);
wvf = wvfSet(wvf,'zcoeffs',2,'defocus');

% Pull out the parameters we need for the search
thisWaveUM  = wvfGet(wvf,'wave','um');
thisWaveNM  = wvfGet(wvf,'wave','nm');
pupilSizeMM = wvfGet(wvf,'pupil size','mm');
pupilPlaneSizeMM = wvfGet(wvf,'pupil plane size','mm',thisWaveNM);

nPixels   = wvfGet(wvf,'spatial samples');
wvf       = wvfComputePSF(wvf);
psfTarget = wvfGet(wvf,'psf');
% wvfPlot(wvf,'image psf space','um')

f = @(x) psf2zcoeff(x,psfTarget,pupilSizeMM,pupilPlaneSizeMM,thisWaveUM, nPixels);

zcoeffs = wvfGet(wvf,'zcoeffs');
nCoeffs = 6;
zcoeffs(1:nCoeffs)
x0 = zeros(size(zcoeffs(1:nCoeffs)));
options = optimset('PlotFcns',@optimplotfval);
x = fminsearch(f,x0,options);

wvf2 = wvfSet(wvf,'zcoeffs',x);
wvf2 = wvfComputePSF(wvf2);
wvfPlot(wvf2,'image psf space','um')
%}

% Programming
% CONSIDER fminunc

% Samples in the pupil plane - Could be precomputed
pupilPos = (0:(nPixels-1))*(pupilPlaneSizeMM/nPixels)-pupilPlaneSizeMM/2;
[xpos, ypos] = meshgrid(pupilPos);
ypos = ypos(end:-1:1,:);

% This scalar could be passed in and adjusted for experiments.  Just
% not yet.  Someone remind me of the name of this term, please!
% (Apodization).
%{
    A = ones(nPixels,nPixels);
%}

% The Zernike polynomials are defined over the unit disk.  At
% measurement time, the pupil was mapped onto the unit disk, so we
% do the same normalization here to obtain the expansion over the
% disk.
%
% And by convention expanding gives us the wavefront aberrations in
% microns.
norm_radius = (sqrt(xpos.^2+ypos.^2))/(pupilPlaneSizeMM/2);
theta = atan2(ypos,xpos);
norm_radius_index = norm_radius <= 1;
% All the way to here

% We keep the first entry 0 ('piston') because it has no impact on the PSF,
% according to a note in t_wvfZernike. Can I find a reference for that?
zcoeffs(1) = 0;

% Get Zernike coefficients and add in appropriate info to defocus
% Need to make sure the c vector is long enough to contain defocus
% term, because we handle that specially and it's easy just to make
% sure it is there.  This wastes a little time when we just compute
% diffraction, but that is the least of our worries.
if (length(zcoeffs) < 5),  zcoeffs(length(zcoeffs)+1:5) = 0; end

% We don't defocus for human chromatic aberration in ISET.  But we do this
% sort of thing in ISETBio.
% zcoeffs(5) = zcoeffs(5) + lcaMicrons + defocusCorrectionMicrons;

% This loop uses the function zerfun to compute the Zernike
% polynomial of each required order. That function normalizes a bit
% differently than the OSA standard, with a factor of 1/sqrt(pi)
% that is not part of the OSA definition.  We correct by
% multiplying by the same factor.
%
% Also, we speed this up by not bothering to compute for zcoeff entries
% that are 0.
wavefrontAberrationsUM = zeros(size(xpos));
for k = 1:length(zcoeffs)
    if (zcoeffs(k) ~= 0)
        osaIndex = k-1;
        [n,m] = wvfOSAIndexToZernikeNM(osaIndex);
        wavefrontAberrationsUM(norm_radius_index) =  ...
            wavefrontAberrationsUM(norm_radius_index) + ...
            zcoeffs(k)*sqrt(pi)*...
            zernfun(n,m,norm_radius(norm_radius_index),theta(norm_radius_index),'norm');
    end
end

% Here is the phase of the pupil function, with unit amplitude
% everywhere
% wavefrontaberrations = wavefrontAberrationsUM;
pupilfuncphase = exp(-1i * 2 * pi * wavefrontAberrationsUM/thisWaveUM);

% Set values outside the pupil we're calculating for to 0 amplitude
pupilfuncphase(norm_radius > pupilSizeMM/pupilPlaneSizeMM)=0;

% Multiply phase by the pupil function amplitude function.
% Important to zero out before this step, because computation of A
% doesn't know about the pupil size.
% pupilfunc{ii} = A.*pupilfuncphase;
pupilfunc = pupilfuncphase;

amp   = fft2(pupilfunc);
inten = (amp .* conj(amp));   %intensity
psf   = real(fftshift(inten));
    
% Scale for unit area
psf = psf/sum(psf(:));

% RMSE
err = rms(psfTarget(:) - psf(:));

end
