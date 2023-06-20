function wvf = wvfPupilFunction(wvf, varargin)
% Compute the pupil fuction from the wvf parameters
%
% Syntax:
%   wvf = wvfPupilFunction(wvf, varargin)
%
% Description:
%    This version of the pupil function calculation is designed for
%    general optics.  See wvfComputePupilFunction for the ISETBio
%    calculations that include Stiles Crawford, human chromatic
%    aberration and parameters related to typical human pupil sizes.
%
%    The pupil function is a complex number that represents the amplitude
%    and phase of the wavefront across the pupil. The returned pupil
%    function at a specific wavelength is
%
%       pupilF = A exp(-1i 2 pi (phase/wavelength));
%
%    The pupil function is related to the PSF by the Fourier transform. See
%    J. Goodman, Intro to Fourier Optics, 3rd ed, p. 131. (MDL)
%
%    The pupil function is calculated for 10 orders of Zernike coeffcients
%    specified to the OSA standard, with the convention that we include the
%    j = 0 term, even though it does not affect the psf. Thus the first
%    entry of the passed coefficients corresponds to j = 1. Adding in the
%    j = 0 term does not change the psf. The spatial coordinate system is
%    also OSA standard.
%
% Inputs:
%    wvf     - The wavefront object
%
% Optional key/value pairs:
%    amplitude - An image describing the amplitude.  The default
%                amplitude across the pupil is assumed to be 1.
% Outputs:
%    wvf     - The wavefront object with the computed data
%
%
% See Also:
%    wvfCreate, wvfGet, wfvSet, wvfComputePSF
%

% History:

% Examples:
%{
% Diffraction limited
 wvf = wvfCreate;
 wvf = wvfPupilFunction(wvf);
 wvf = wvfComputePSF(wvf);
 wvfPlot(wvf,'psf','um',550,10);
%}
%{
 wvf = wvfCreate;    % Diffraction
 A = rand(201,201);
 wvf = wvfPupilFunction(wvf,'amplitude',A);
 wvf = wvfComputePSF(wvf);
 wvfPlot(wvf,'psf','um',550,10);
%}
%{
 wvf = wvfCreate;    % Diffraction
 pupilAmp = wvfPupilAmplitude(wvf,'nsides',6);
 wvf = wvfPupilFunction(wvf,'amplitude',pupilAmp);
 wvf = wvfComputePSF(wvf);
 wvfPlot(wvf,'psf','um',550,10);
%}


%% Input parse
%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('wvf',@isstruct);
p.addParameter('amplitude',[],@ismatrix);  % Pupil amplitude mask

% varargin = wvfKeySynonyms(varargin);
p.parse(wvf,varargin{:});
amplitude = p.Results.amplitude;

% Convert wavelengths in nanometers to wavelengths in microns
waveUM = wvfGet(wvf, 'calc wavelengths', 'um');
waveNM = wvfGet(wvf, 'calc wavelengths', 'nm');
nWavelengths = wvfGet(wvf, 'number calc wavelengths');

% Compute the pupil function
%
% This needs to be done separately at each wavelength because the size
% in the pupil plane that we sample is wavelength dependent.
pupilfunc   = cell(nWavelengths, 1);
areapix     = zeros(nWavelengths, 1);
areapixapod = zeros(nWavelengths, 1);
wavefrontaberrations = cell(nWavelengths, 1);

nPixels = wvfGet(wvf, 'spatial samples');

% Set up the amplitude function.  Only one function for all wavelengths at
% this time.  But it should probably be wavelength dependent.
if isempty(amplitude)
    A = ones(nPixels, nPixels);
    A = imageCircular(A);
else                  
    A = imresize(amplitude,[nPixels,nPixels]);
end
% ieNewGraphWin; imagesc(A); axis image

pupilDiameterMM = wvfGet(wvf,'calc pupil diameter','mm');

for ii = 1:nWavelengths
    thisWave = waveNM(ii);   

    % Set up pupil coordinates
    pupilPlaneSizeMM = wvfGet(wvf, 'pupil plane size', 'mm', thisWave);
    pupilPos = (1:nPixels) - (floor(nPixels / 2) + 1);
    pupilPos = pupilPos * (pupilPlaneSizeMM / nPixels);

    % Do the meshgrid thing and flip y. Empirically the flip makes
    % things work out right.
    [xpos, ypos] = meshgrid(pupilPos);
    ypos = -ypos;

    % The Zernike polynomials are defined over the unit disk. At
    % measurement time, the pupil was mapped onto the unit disk, so we
    % do the same normalization here to obtain the expansion over the
    % disk.
    %
    % And by convention expanding gives us the wavefront aberrations in
    % microns.
    %
    % Normalized radius here.  Distance from the center divided by the
    % pupil radius.
    norm_radius = (sqrt(xpos .^ 2 + ypos .^ 2)) / (pupilDiameterMM / 2);
    theta = atan2(ypos, xpos);
    % ieNewGraphWin; imagesc(norm_radius); axis square

    % Only values that are within the unit circle are valid for the Zernike
    % polynomial. 
    norm_radius_index = (norm_radius <= 1);
    % The indices within the unit radius
    % ieNewGraphWin; imagesc(norm_radius_index); axis image   

    % We place the amplitude function within the region defined by the
    % valid radius.  
    % 
    % Find the bounding box of the circle. 
    boundingBox = imageBoundingBox(norm_radius_index);

    % Resize the amplitude mask to the square over the central circle
    A = imresize(A,[boundingBox(3),boundingBox(4)]);
   
    % Pad with zeros to match the pupil phase size.
    sz = round((nPixels - boundingBox(3))/2);
    A = padarray(A,[sz,sz],0,'both');    
    A = imresize(A,[nPixels,nPixels]);

    % Keep the amplitude within bounds
    A(A > 1) = 1;
    A(A < 0) = 0;
    % ieNewGraphWin; imagesc(A); axis image

    % Get Zernike coefficients and add in appropriate info to defocus
    % Need to make sure the c vector is long enough to contain defocus
    % term, because we handle that specially and it's easy just to make
    % sure it is there. This wastes a little time when we just compute
    % diffraction, but that is the least of our worries.
    c = wvfGet(wvf, 'zcoeffs');
    if (length(c) < 5), c(length(c) + 1:5) = 0; end

    % This loop uses the function zernfun to compute the Zernike
    % polynomial of each required order. That function normalizes a bit
    % differently than the OSA standard, with a factor of 1/sqrt(pi)
    % that is not part of the OSA definition. We correct by
    % multiplying by sqrt(pi).
    %
    % Also, we speed this up by not bothering to compute for c entries
    % that are 0.
    wavefrontAberrationsUM = zeros(size(xpos));
    for k = 1:length(c)
        if (c(k) ~= 0)
            osaIndex = k - 1;
            [n, m] = wvfOSAIndexToZernikeNM(osaIndex);
            wavefrontAberrationsUM(norm_radius_index) =  ...
                wavefrontAberrationsUM(norm_radius_index) + ...
                c(k)*sqrt(pi)*zernfun(n, m, norm_radius(norm_radius_index), ...
                theta(norm_radius_index), 'norm');
        end
    end

    % Here is phase of the pupil function, w/ unit amplitude everywhere
    wavefrontaberrations{ii} = wavefrontAberrationsUM;
    pupilfuncphase = exp(-1i * 2 * pi * wavefrontAberrationsUM / waveUM(ii));
    % ieNewGraphWin; imagesc(wavefrontAberrationsUM);

    % Set values outside the pupil to 0 amplitude.  Though possibly
    % this should all be part of the amplitude mask, A.  These are the
    % values not in the norm_radius_index calculated above.
    pupilfuncphase(norm_radius>0.5) = 1;
    % ieNewGraphWin; imagesc(angle(pupilfuncphase));

    % Multiply phase by the pupil function amplitude function.
    % Important to zero out before this step, because computation of A
    % doesn't know about the pupil size.
    pupilfunc{ii} = A .* pupilfuncphase;
    % ieNewGraphWin; imagesc(angle(pupilfunc{ii})); axis image
    % ieNewGraphWin; imagesc(abs(pupilfunc{ii})); axis image;

    % We think the ratio of these two quantities tells us how much
    % light is effectively lost in cone absorbtions because of the
    % Stiles-Crawford effect. They might as well be computed here,
    % because they depend only on the pupil function and the sce params
    areapix(ii) = sum(sum(abs(pupilfuncphase)));
    areapixapod(ii) = sum(sum(abs(pupilfunc{ii})));
    
end

% We think the aberrations are in microns (BW).    But look at
% t_wvfWatsonJOV for a comparison and some concern.
wvf.wavefrontaberrations = wavefrontaberrations;
wvf.pupilfunc = pupilfunc;
wvf.areapix = areapix;
wvf.areapixapod = areapixapod;

% Let the rest of the code know we computed the pupil function and
% that a new PSF will be needed.
wvf.PUPILFUNCTION_STALE = false;
wvf.PSF_STALE = true;

end

