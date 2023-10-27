function wvf = wvfComputePSF(wvf, showBar, varargin)
% Compute the psf for the wvf object. 
%
% Syntax:
%   wvf = wvfComputePSF(wvf, [showbar])
%
% Description:
%    If the psf is already computed and not stale, this will return fast.
%    Otherwise it computes and stores.
%
%    The point spread function is computed for each of the wavelengths
%    listed in the input wvf structure. The PSF computation is based on 10
%    orders of Zernike coefficients specified to the OSA standard.
%
%    The calculation also assumes that there is chromatic aberration of the
%    human eye, as embedded in the function wvfLCAFromWavelengthDifference, 
%    within the code in wvfComputePupilFunction.
%
%    Based on code provided by Heidi Hofer.
%
% Inputs:
%    wvf     - wavefront object
%    showbar - (Optional) Boolean dictating whether or not to show the
%              calculation wait bar. Default false.
%
% Outputs:
%    wvf     - The wavefront object
%
% Optional key/value pairs:
%    None.
%
% See Also:
%    wvfGet, wvfCreate, wvfSet, wvfComputePupilFunction, 
%    wvfLCAFromWavelengthDifference
%

% History:
%    08/20/11  dhb  Rename function and pull out of supplied routine.
%                   Reformat comments.
%    09/05/11  dhb  Rename. Rewrite for wvf i/o.
%    xx/xx/12       Copyright Wavefront Toolbox Team 2012
%    06/02/12  dhb  Simplify greatly given new get/set conventions.
%    07/01/12   bw  Adjusted for new wavelength convention
%    11/08/17  jnm  Comments & formatting
%    01/18/18  jnm  Formatting update to match Wiki, a couple cosmetic bits

% Examples:
%{
    wvf = wvfCreate;
    wvf = wvfComputePSF(wvf)
%}

%% Input parses
%
% Run ieParamFormat over varargin before passing to the parser,
% so that keys are put into standard format
p = inputParser;
p.addParameter('nolca',false,@islogical);
ieVarargin = ieParamFormat(varargin);
ieVarargin = wvfKeySynonyms(ieVarargin);
p.parse(ieVarargin{:});

%% 
if notDefined('showBar'), showBar = false; end

% Only calculate if we need to -- PSF might already be computed and stored
if (~isfield(wvf, 'psf') || ~isfield(wvf, 'PSF_STALE') || ...
        wvf.PSF_STALE || ~isfield(wvf, 'pupilfunc') || ...
        ~isfield(wvf, 'PUPILFUNCTION_STALE') || wvf.PUPILFUNCTION_STALE) 
  
    % Initialize parameters. These are calc wave.
    wList = wvfGet(wvf, 'calc wave');
    nWave = wvfGet(wvf, 'calc nwave');
    flipPSFUpsideDown = wvfGet(wvf, 'flippsfupsidedown');
    rotatePSF90degs = wvfGet(wvf, 'rotatepsf90degs');
    pupilfunc = cell(nWave, 1);

    % Make sure pupil function is computed. This function incorporates the
    % chromatic aberration of the human eye.
    wvf = wvfComputePupilFunction(wvf, showBar,'nolca',p.Results.nolca);

    % wave = wvfGet(wvf, 'wave');
    psf = cell(nWave, 1);
    for wl = 1:nWave
        % Convert the pupil function to the PSF.
        % Requires only an fft2. 
        % Scale so that psf sums to unity.
        pupilfunc{wl} = wvfGet(wvf, 'pupil function', wList(wl));

        % Compute fft of pupil function to obtain the psf.
        % The insertion of the ifftshift before the fft2 is because the
        % pupil function is centered on its support, and we think that in
        % Matlab-land, we should insert ifftshift before transforming
        % centered data.
        %
        % We convert to intensity because that is how Fourier optics works.
        amp = fftshift(fft2(ifftshift(pupilfunc{wl})));
        inten = (amp .* conj(amp));
        
        % Given the way we computed intensity, should not need to take the
        % real part, but this way we avoid any very small imaginary bits
        % that arise because of numerical roundoff.
        psf{wl} = real(inten);
        
        % We used to not use the ifftshift. Indeed, the ifftshift does not
        % seem to matter here, but my understanding of the way fft2 works, 
        % we want it.  The reason it doesn't matter is because we don't
        % care about the phase of the fft.  Set DOCHECKS here to true to
        % recompute the old way and verify that we get the same answer to
        % numerical precision. And a few other things.
        DOCHECKS = false;
        if (DOCHECKS)
            amp1 = fft2(pupilfunc{wl});
            inten1 = fftshift((amp1 .* conj(amp1)));
            if (max(abs(inten(:) - inten1(:))) > 1e-8 * mean(inten(:)))
                fprintf(['The ifftshift matters in computation of psf ' ...
                    'from pupil function\n']);
            end
            if (max(abs(amp(:) - amp1(:))) > 1e-8 * mean(amp(:)))
                fprintf(['The ifftshift matters in computation of amp ' ...
                    'from pupil function, as expected.\n']);
            end
            if (max(abs(imag(inten(:)))) > 1e-8 * mean(inten(:)))
                fprintf(['Max absolute value of imaginary part of ' ...
                    'inten is %g\n'], max(abs(imag(inten(:)))));
            end
        end
        
        % Make sure psf sums to unit volume.
        psf{wl} = psf{wl} / sum(sum(psf{wl}));

        if (flipPSFUpsideDown)
            % Flip PSF upside down
            psf{wl} = flipud(psf{wl});
        end
        

        if (rotatePSF90degs)
            % Flip PSF left right 
            psf{wl} = rot90(psf{wl});
        end
        
    end
    
    wvf.psf = psf;
    wvf.PSF_STALE = false;
end

end
