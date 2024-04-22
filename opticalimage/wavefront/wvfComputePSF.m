function wvf = wvfComputePSF(wvf, varargin)
% Compute the psf for the wvf object.
%
% Syntax:
%   wvf = wvfComputePSF(wvf, varargin)
%
% Description:
%    Compute the psf from the pupil function.  We assume the pupil
%    function has already been computed (wvfComputePupilFunction).
%    Or, you can set the flag to true to force a new computation.
%
%    The point spread function is computed for each of the wavelengths
%    listed in the input wvf structure. The PSF computation is based on 10
%    orders of Zernike coefficients specified to the OSA standard.
%
%    The calculation can incorpirate chromatic aberration or not,
%    according to the LCA flag. If true, LCA uses the chromatic
%    aberration of the human eye, as embedded in the function
%    wvfLCAFromWavelengthDifference, within the code in
%    wvfComputePupilFunction.
%
% Inputs:
%    wvf     - wavefront struct
%
% Optional key/value pairs:
%     lca - Include human longitudinal chromatic aberration in the pupil
%           function
%     compute pupil func - Force recomputation of the pupil function
%
% Outputs:
%    wvf     - The wavefront struct
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
%    07/04/23  baw  Many

% Examples:
%{
 wl = 550;
 wvf = wvfCreate('wave',wl);
 wvf = wvfComputePSF(wvf,'compute pupil func',true);
 wvfPlot(wvf,'psf','unit','um','wave',wl,'plot range',20,'airy disk',true);
%}

%% Input parsing

% ieParamFormat so that keys are put into standard format (no spaces,
% all lower case).
varargin = ieParamFormat(varargin);

p = inputParser;
p.addParameter('humanlca',false,@islogical);      % Use longitudinal chromatic aberration
p.addParameter('computepupilfunc',false,@islogical); % Do NOT force pupil function computation

varargin = wvfKeySynonyms(varargin);

p.parse(varargin{:});

%% Initialize parameters. These are calc wave.
wList = wvfGet(wvf, 'calc wave');
nWave = wvfGet(wvf, 'calc nwave');
flipPSFUpsideDown = wvfGet(wvf, 'flippsfupsidedown');
rotatePSF90degs = wvfGet(wvf, 'rotatepsf90degs');
pupilfunc = cell(nWave, 1);

% Compute the pupil function, if needed.
%
% By default, wvf uses the chromatic aberration of the human eye.
% But we can turn that off here setting 'lca' parameter to false.
% The wvfComputePupilFunction only as the 'no lca' parameter,
% which is the logical complement.
%
% Also, this function may not force a new computation of the pupil
% function.  We can set the 'force' parameter to true, to force.
if p.Results.computepupilfunc
    wvf = wvfCompute(wvf,'human lca',p.Results.humanlca);
end

% wave = wvfGet(wvf, 'wave');
psf = cell(nWave, 1);
for wl = 1:nWave
    % Convert the pupil function to the PSF.
    % Requires only an fft2.
    % Scale so that psf sums to unity.
    pupilfunc{wl} = wvfGet(wvf, 'pupil function', wList(wl));

    % Compute fft of the pupil function to obtain the psf. The
    % insertion of the ifftshift before the fft2 is because the pupil
    % function is centered on its support, and in Matlab-land, we need
    % to insert ifftshift before transforming centered data.
    %
    amp = fftshift(fft2(ifftshift(pupilfunc{wl})));

    % We convert to intensity because the PSF is an intensity (real)
    % valued function. That is how Fourier optics works.
    inten = (amp .* conj(amp));

    % Given the way we computed intensity, should not need to take the
    % real part, but this way we avoid any very small imaginary bits
    % that arise because of numerical roundoff.
    psf{wl} = real(inten);

    %{
        % BW:  Commented out because DOCHECKS = false for several years.
        %
        % BW: I set DOCHECKS to true, but commented the code out for now.  
        % Running tests, the 'as expected' part prints out but not the other two.
        %
        % Old notes (maybe DHB?)
        % We used to not use the ifftshift. Indeed, the ifftshift does not
        % seem to matter here, but my understanding of the way fft2 works, 
        % we want it.  The reason it doesn't matter is because we don't
        % care about the phase of the fft for the PSF.
        % We can put this back and set DOCHECKS here to true to
        % recompute the old way and verify that we get the same answer to
        % numerical precision. And a few other things.        
        DOCHECKS = true;
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
    %}

    % Make sure psf sums to unit volume.  This means that a constant
    % value input passes through the optics with the same constant
    % value.
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
