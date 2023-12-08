function [conePsf, coneSceFraction] = wvfComputeConePSF(wvf)
% Return cone PSF and cone SCE Fraction using a wavefront object with PSF
%
% Syntax:
%   [conePsf, coneSceFraction] = wvfComputeConePSF(wvf)
%
% Description:
%    This routine finds PSFs seen by each cone class under passed spectrum
%    weightingSpectrum. It gets these by taking a weighted sum of the
%    monochromatic PSFs, where the weights are given by the product of the
%    LMS spectral sensitivities and the weighting spectrum.
%
%    Note that we wouldn't generally call this directly, but rather use
%      conePsf = wvfGet(wvf, 'cone psf')
%    which in turn would call this.
%
%    The returned psfs are normalized so that they sum to unity. If you
%    want to figure out the relative amount of light seen by each cone
%    class, you need to take the spectral sensitivities into account and
%    also the SCE if you're using that.
%
%    The routine also returns the weighted average of the monochromatic
%    sceFraction entries for each cone type, to make knowing this easier.
%    We still need to do some conceptual thinking about exactly what this
%    quantity means and how to use it.
%
%    If you actually know the hyperspectral image input, you probably don't
%    want to use this routine. Rather, compute the monochromatic PSFs at
%    each wavelength and do your optical blurring in the wavelength domain, 
%    before computing cone absorbtions. Doing so is a more accurate model
%    of the physics. You would use this routine under two circumstances.
%    First, you might know that the image consists only of intensity
%    modulations of a single relative spectrum. In this case, you could
%    use that spectrum here and speed things up, since you'd only have to
%    convolve three times (one for each cone class rather than once for
%    each wavelength). This case corresponds, for example, to psychophysics
%    where achromatic contrast is manipulated. Second, you might only know
%    the unblurred LMS images and not have spectral data. Then, this
%    routine is useful for providing an approximation to the blurring that
%    will occur for each cone class. For example, your data might originate
%    with a high-resolution RGB camera image, which was then used to
%    estimate LMS values at each location. Keep in mind that what you get
%    in that case is only an approximation, since the actual blur depends
%    on the full spectral image.
% 
%    If you want to compute a strehl ratio quantity for the LMS psfs, the
%    most straightforward way is to call this routine a second time using a
%    zcoeffs vector of all zeros. This leads to computation of diffraction
%    limited monochromatic psfs that are then summed just like the
%    specified ones. Taking the ratios of the peaks then gives you a
%    fairly meaningful figure of merit.
%
%     Examples are provided in the code.
%
% Inputs:
%    wvf             - The wavefront object (with PSF already calculated)
%
% Outputs:
%    conePSF         - The normalized cone PSFs. This is returned as a
%                      matrix, with the third dimension indexing cone type.
%                      Cone types are specified by the spectral sensitivies
%                      in the wvf structures conePsfInfo structure:
%                      wvfGet(wvf, 'calc cone psf info');
%    coneSceFraction - Weighted average of the monochromatic SCE fraction
%
% Optional key/value pairs:
%    None.
%
% See Also:
%    wvfGet, wvfComputePSF, conePsfInfoCreate, conePsfInfoGet
%

% History:
%    07/13/07  dhb  Made into a callable function, based on code provided
%                   by Heidi Hofer. Remove globals, fix case of fft, get
%                   rid of some vars we don't care about. Don't write files
%                   here, optional plot supression.
%    07/14/07  dhb  Change name a little.
%    12/22/09  dhb  Return monochromatic PSFs as a cell array
%    08/21/11  dhb  Update
%    09/07/11  dhb  Rename. Use wvf for i/o.
%    07/20/12  dhb  Got this to run again in its modern form.
%    11/10/17  jnm  Formatting
%    01/15/18  dhb  Got this to run with conePsfInfo and added example.
%    01/17/18  jnm  Formatting update to match wiki.

% Examples:
%{
    % Compute cone weighted PSFs using default parameters for conePsfInfo.
    wvf = wvfCreate('wave', 400:10:700);
    wvf = wvfCompute(wvf,'humanlca',true);
    [cPSF, cSceFrac] = wvfComputeConePSF(wvf);

    % Should get the answer using the wvfGet call.
    cPSF1 = wvfGet(wvf, 'conepsf');
    if (any(cPSF(:) ~= cPSF1(:)))
       fprintf('Oops. Call to wvfComputeConePSF does not match wvfGet\n');
    end

    % Look at how blurry that S cone PSF is, even for the diffraction
    % limited case!
    figure;
    clf;
    hold on
    [m, n, k] = size(cPSF);
    plot(cPSF(floor(m / 2) + 1, :, 1) ...
        / max(cPSF(floor(m / 2) + 1, :, 1)), 'r', 'LineWidth', 3);
    plot(cPSF(floor(m / 2) + 1, :, 2) ...
        / max(cPSF(floor(m / 2) + 1, :, 2)), 'g', 'LineWidth', 2);
    plot(cPSF(floor(m / 2) + 1, :, 3) ...
        / max(cPSF(floor(m / 2) + 1, :, 3)), 'b', 'LineWidth', 1);
    xlim([0 201]);
    xlabel('Position (arbitrary units');
    ylabel('Cone PSF');
%}

%% Get wavelengths
wls = wvfGet(wvf, 'calc wavelengths');
nWls = length(wls);

% Need to use S so that spline of spectral weighting
% won't crash out if just a single wavelength is used.
% Since weighting vector is normalized, we can use any
% delta lambda that isn't zero. Just use 1.
if numel(wls(:)) == 1
    S = [wls(1) 1 1];
else
    S = WlsToS(wls);
end

%% Check sanity of spatial sampling across wavelengths.
%
% See note on spatial sampling parameters in the code in wvfSet. We
% expect constant spatial sampling of the psf so we check that such 
% is set. The code here implements various sanity checks, and is certainly
% overkill as long as we're confident the underlying wvf code is doing what
% it is supposed to. 
%
% Make sure flag is set right. This we should continue to do.
if (~strcmp(wvfGet(wvf, 'sample interval domain'), 'psf'))
    error('Must set wvf for constant spatial sampling in psf domain');
end

% Check that psf spatial samples returns the same answer at all
% wavelengths.
firstPsfSpatialSamples= wvfGet(wvf, 'psf spatial samples', 'um', wls(1));
for ww = 1:nWls
    checkPsfSpatialSamples = wvfGet(wvf, 'psf spatial samples', ...
        'um', wls(ww));
    if (any(firstPsfSpatialSamples(:) ~= checkPsfSpatialSamples(:)))
        error(['Inconsistent psf spatial sampling interval ' ...
            'across wavelengths']);
    end  
end

% Make sure that psf angular samples returns the same number at all
% wavelengths.
firstPsfAngularSamples = wvfGet(wvf, 'psf angular samples', 'min', wls(1));
for ww = 1:nWls
    checkPsfAngularSamples = wvfGet(wvf, 'psf angular samples', ...
        'min', wls(ww));
    if (any(firstPsfAngularSamples(:) ~= checkPsfAngularSamples(:)))
        error(['Inconsistent psf angular sampling interval ' ...
            'across wavelengths']);
    end  
end

% This commented out code is trying to understand the relation between what
% is returned as the ref psf sample interval and psf spatial samples. They
% don't match. I think that's because the ref sample interval is an
% abstract quantity that serves as a base value for setting up the spatial
% samples, but that doesn't necessarily match them. See issue 307. This
% code may be deleted once we verify that my conjecture is correct, but am
% leaving it here for now as a way to investigate.
%
% refPsfSpatialSampleIntervalMin = wvfGet(wvf, ...
%     'ref psf sample interval', 'min');
% firstPsfSpatialSamplesMin = wvfGet(wvf, 'psf spatial samples', ...
%     'min', wls(1));
% if (firstPsfSpatialSamplesMin(2) - firstPsfSpatialSamplesMin(1) ...
%         ~= refPsfSpatialSampleIntervalMin)
%     error('Surprised about psf sampling');
% end

%% Get weighted cone fundamentals, and normalize each weighting function.
conePsfInfo = wvfGet(wvf, 'calc cone psf info');
T = SplineCmf(conePsfInfoGet(conePsfInfo, 'wavelengths'), ...
    conePsfInfoGet(conePsfInfo, 'spectralSensitivities'), wls);
spdWeighting = SplineSpd(conePsfInfoGet(conePsfInfo, 'wavelengths'), ...
    conePsfInfoGet(conePsfInfo, 'spectralWeighting'), S);
spdWeighting = spdWeighting/sum(spdWeighting);
nCones = size(T, 1);
coneWeight = zeros(nCones, nWls);
for j = 1:nCones
    coneWeight(j, :) = T(j, :) .* spdWeighting';
    coneWeight(j, :) = coneWeight(j, :) / sum(coneWeight(j, :));
end

%%
% Get psfs for each wavelength. This comes back as a cell array unless
% there is only one wavelengt.
psf = wvfGet(wvf, 'psf');

%% Get fraction of light at each wavelength lost to sce
sceFraction = wvfGet(wvf, 'sce fraction', wls);

%% Weight up cone psfs
%
% Need to handle case of one wavelength separately because this doesn't
% come back as a cell array.
if (nWls == 1)
    [m, n] = size(psf);
    conePsf = zeros(m, n, nCones);
    for j = 1:nCones
        conePsf(:, :, j) = sceFraction * coneWeight(j) * psf;
    end
else
    [m, n] = size(psf{1});
    conePsf = zeros(m, n, nCones);
    for j = 1:nCones
        for wl = 1:nWls
            [m1, n1] = size(psf{wl});
            if (m1 ~= m || n1 ~= n)
                error(['Pixel size of individual wavelength PSFs does '...
                    'not match']);
            end
            conePsf(:, :, j) = conePsf(:, :, j) + ...
                sceFraction(wl) * coneWeight(j, wl) * psf{wl};
        end
    end
end

% Normalize each PSF to unit volume.
for j = 1:nCones
    conePsf(:, :, j) = conePsf(:, :, j) / sum(sum(conePsf(:, :, j)));
end

% Get sceFraction for each cone type
for j = 1:nCones
    coneSceFraction(j, :) = coneWeight(j, :) .* sceFraction';
end
