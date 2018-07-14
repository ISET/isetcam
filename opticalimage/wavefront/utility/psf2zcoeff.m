function err = psf2zcoeff(zcoeffs,psfTarget,pupilSizeMM, pupilPlaneSizeMM, thisWaveUM, nPixels)
% Error function evaluating how well a set of ZCoeffs produce a psf
%
% See how these are calculated in the wvfComputePupilFunction
%
% CONSIDER fminunc
%
% This seems like the way to do the call.  zcoeffs are the parameters we
% vary, the fixed values are set in the work environment.
% The anonymous function calls psf2zcoeff.  Its first argument will be the
% zcoeffs, and fminsearch will search across those.  The other arguments
% will be taken from the work environment.
%{
psfTarget = 
pupilSizeMM = ...
pupilPlaneSizeMM = 
psfTarget   = ...
thisWaveUM = ...
nPixels = ...
f = @(x)(psf2zcoeff(x,psfTarget,pupilSizeMM,...)
x0 = [zcoeffs(:)']
x = fminsearch(f,x0))
%}
% This seems like the way we get the environmental variables prior
% to the call
% pupilPlaneSizeMM - wvfGet(wvf,'pupil plane size','mm',thisWaveNM);
% thisWaveUM  - waveNM(ii)/1000;
% nPixels     - nPixels = wvfGet(wvf,'spatial samples');
% zcoeffs     - Zernike coefficients zcoeffs = wvfGet(wvf,'zcoeffs');
% pupilSizeMM - pupilSizeMM = wvfGet(wvf,'pupil size','mm');
%
% BW, Vistasoft Team, 2018

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

% Get Zernike coefficients and add in appropriate info to defocus
% Need to make sure the c vector is long enough to contain defocus
% term, because we handle that specially and it's easy just to make
% sure it is there.  This wastes a little time when we just compute
% diffraction, but that is the least of our worries.
if (length(zcoeffs) < 5),  zcoeffs(length(zcoeffs)+1:5) = 0; end
% We don't defocus for human chromatic aberration in ISET
% c(5) = c(5) + lcaMicrons + defocusCorrectionMicrons;

% This loop uses the function zerfun to compute the Zernike
% polynomial of each required order. That function normalizes a bit
% differently than the OSA standard, with a factor of 1/sqrt(pi)
% that is not part of the OSA definition.  We correct by
% multiplying by the same factor.
%
% Also, we speed this up by not bothering to compute for c entries
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

amp = fft2(pupilfunc);
inten = (amp .* conj(amp));   %intensity
psf = real(fftshift(inten));
    
% Scale for unit area
psf = psf/sum(sum(psf));

% RMSE
err = norm(psfTarget(:) - psf(:),2);

end
