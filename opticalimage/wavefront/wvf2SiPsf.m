function [siData, wvfP] = wvf2SiPsf(wvfP, varargin)
% Convert a wvf structure to isetbio shift-invariant PSF data structure
%
% Syntax:
%   [siData, wvfP] = wvf2SiPsf(wvfP, [varargin])
%
% Description:
%    For each wavelength in wvfP, compute the PSF place it into an isetbio
%    (inheritied from iset) shift-invariant PSF structure that can then be
%    passed smoothly into an optical image structure in isetbio.
%
%    Note that we also have wvf2oi, which converts the PSF specified by the
%    wavefront structure into an optical image (oi) structure. That may
%    really be what you want to do.
%
%    The input wvfP is the main wavefront optics toolbox structure. The PSF
%    is computed at the wavelength values in the structure. The updated
%    structure with the PSFs can be obtained via wvfGet calls.
%
%    The output siData structure is an iset/isetbio structure that
%    describes shift invariant PSFs. We convert to this structure, because
%    then we already have code that knows how to push this into an optical
%    image structure.
%
%    You need to think a litte bit about how to choose the number of
%    samples and um per pixel onto which the PSF will be computed. For
%    human retina, there are about 300 um per degree and foveal cone
%    spacing is about 0.3 um. Typical PSFs are bigger than a cone  If you
%    use the default values of 128 samples and 0.25 um/pixel, the PSF will
%    probably be sampled OK as and captured reasonably well for many use
%    cases. But it is probably worth plotting you compute to make sure this
%    is true.
%
%    Note also that is some places, the siData structure is currently
%    assumed to have 128 samples, so changing this to be what you need
%    might cause something else to break.
%
%    If you don't want to use wvf2oi, or if you want an optics structure
%    rather than an oi, you could create the optics structure directly
%    using siSynthetic, and then stick that into an optical image
%    structure. This is illustrated in the Examples section below.
%
%    The siData-format PSF data can be saved using ieSaveSIDataFile as
%    illustrated in the Examples section below, for example if you wanted
%    to pre-compute some PSFs and then load them later.
%
% Inputs:
%    wvfP    - Wavefront Optics Toolbox structure
%    showBar - (Optional) Boolean indicating whether or not to show the
%              wait bar. The default is true.
%
% Outputs:
%    siData  - Shift-Invariant PSF format used for human optics simulation
%    wvfP    - Wavefront structure updated with PSF computed via
%              wvfP = wvfComputePSF(wvfP).  Returned only because this can
%              be a little slow and we might want it in the caller.
%
% Optional key/value pairs:
%    showBar -     Boolean, show the wait bar? (Default false)
%    nPSFSamples - Scalar, number of x and y samples to use when computing
%                  the PSF for the siData structure. (Default 128)
%    umPerSample - Scalar, number of retinal microns per PSF pixel. The
%                  same number is used for x and y. (Default 0.25)
%
% See Also:
%    wvf2oi, wvfGet, siSynthetic, ieSaveSIDataFile.
%

% History:
%    xx/xx/12       Copyright Imageval 2012
%    11/13/17  jnm  Comments & formatting
%    12/5/17   dhb  Convert to using input parser, not backwards
%                   compatible for showBar arg. Sharpen comments. Add plot
%                   of output to example. Make number of samples for output
%                   and umPerSample parameters that can be set.
%    12/21/17  dhb  Change name. Try to prevent NaN's in interpolated PSFs.
%    01/15/18  dhb  First example was broken.  Fixed. Second example was
%                   also broken, but the desired example is in a tutorial
%                   so pointed to that.
%    01/18/18  jnm  Formatting update to match Wiki.

% Examples:
%{
    % Create wavefront structure with reasonable parameters.
    pupilMM = 6;
    zCoeffs = wvfLoadThibosVirtualEyes(pupilMM);
    wave = [450:100:650]';
    wvfP = wvfCreate('calc wavelengths', wave, ...
        'measured wavelength', 550, ...
        'zcoeffs', zCoeffs, 'measured pupil', pupilMM, ...
        'name', sprintf('human-%d', pupilMM));

    % Set a little defocus, just to make the PSF a bit more interesting
    wvfP = wvfSet(wvfP, 'zcoeff', 0.5, 'defocus');

    % Convert to siData format and save.  201 is the number of default 
    % samples in the wvfP object, and we need to match that here.
    [siPSFData, wvfP] = wvf2SiPsf(wvfP,'showBar',true,'nPSFSamples',201);
    fName = sprintf('psfSI-%s', wvfGet(wvfP, 'name'));
    ieSaveSIDataFile(siPSFData.psf, siPSFData.wave, ...
        siPSFData.umPerSamp, fName);

    % Plot the PSF from the input structure and the siData version.
    %
    % Not sure if [m, n] and [x, y] conventions are right in the siData 
    % plot, but since everything is square here that is OK for now. To fix
    % it, would need to know convention fo umPerSamp vector order as well
    % as that for imagesc.
    vcNewGraphWin([], 'tall');
    subplot(2, 1, 1);
    wvfPlot(wvfP, 'image psf', 'unit','um', 'wave', 550, 'plot range', 15, 'window', gcf);
    [m, n, k] = size(siPSFData.psf);
    samplesy = ((1:m)-mean(1:m))*siPSFData.umPerSamp(1);
    samplesx = ((1:n)-mean(1:n))*siPSFData.umPerSamp(2);
    subplot(2, 1, 2);
    imagesc([samplesx(1), samplesx(end)], [samplesy(1) samplesy(end)], ...
        siPSFData.psf(:, :, 2)); axis('square');
    xlim([-15 15]); ylim([-15 15]);
    
    % Clean up
    delete([fName '.mat']);
%}
%{
    % See this tutorial for use with siSynthetic to create an oi with a 
    % PSF from wvf2SiPsf, plus better ways to start with a wvf and get it
    % into an OI.
    % t_opticsGetAndSetPsf
%}

%% Parameters
p = inputParser;
p.addRequired('wvfP', @isstruct);
p.addParameter('showBar', false, @islogical);
p.addParameter('nPSFSamples', 128, @isscalar);
p.addParameter('umPerSample', 0.25, @isscalar);
p.parse(wvfP, varargin{:});

%% Get info from wvf
wave = wvfGet(wvfP, 'calc wave');
nWave = wvfGet(wvfP, 'calc nwave');

%% Use wvfCompute to compute the psf at all wavelengths
%
% And store result back into the wvf structure. We will get this
% below in a manner that keeps the units clear.
wvfP = wvfCompute(wvfP);

%% Set up to interpolate the PSFs for passing into isetbio.
%
% Set up # of samples for siData PSF and spacing in microns between samples
nPSFSamples = p.Results.nPSFSamples;                  
umPerSample = p.Results.umPerSample;
outSamp = ((1:nPSFSamples) - (floor(nPSFSamples / 2) + 1)) * umPerSample;
outSamp = outSamp(:);
psf = zeros(nPSFSamples, nPSFSamples, nWave);

%% Do the interplation
if p.Results.showBar, wBar = waitbar(0, 'Creating PSF'); end
for ii = 1:nWave
    if (p.Results.showBar), waitbar(ii / nWave, wBar); end
    thisPSF = wvfGet(wvfP, 'psf', wave(ii));
    inSamp = wvfGet(wvfP, 'samples space', 'um', wave(ii));
    inSamp = inSamp(:);
    
    % If the in and out sampling are effectively the same, don't
    % interpolate.  Also, be explicit about extrapval. 0 seems like
    % an excellent choice.  This may also avoid the NaNs.
    if (max(abs(inSamp(:) - outSamp(:))) < 1e-10)
        psf(:, :, ii) = thisPSF;
    else
        psf(:, :, ii) = interp2(inSamp, inSamp', thisPSF, outSamp, ...
            outSamp', 'linear', 0);
    end
end
if (p.Results.showBar), close(wBar); end

%% Store result in well-formed siData structure
siData.psf = psf;
siData.wave = wave;
siData.umPerSamp = [umPerSample umPerSample];

end
