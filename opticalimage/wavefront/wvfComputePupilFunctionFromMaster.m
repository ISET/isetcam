function wvf = wvfComputePupilFunction(wvf, showBar, varargin)
% Compute the pupil fuction given the wvf object.
%
% Syntax:
%   wvf = wvfComputePupilFunction(wvf, [showbar])
%
% Description:
%    The pupil function is a complex number that represents the amplitude
%    and phase of the wavefront across the pupil. The returned pupil
%    function at a specific wavelength is
%       pupilF = A exp(-1i 2 pi (phase/wavelength));
%    The amplitude, A, is calculated entirely based on the assumed
%    properties of the Stiles-Crawford effect.
%
%    This function assumes the chromatic aberration of the human eye. That
%    is embedded in the call to wvfLCAFromWavelengthDifference, within this
%    code.
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
%    Note that this system is the same for both left and right eyes. If the
%    biology is left-right reflection symmetric, one might want to
%    left-right flip the coordinates when computing for the left eye (see
%    OSA document).
%
%    Includes SCE (Stiles-Crawford Effect) if specified. The SCE is modeled
%    as an apodization filter (a spatially-varying amplitude attenuation)
%    to the pupil function. In this case, it is a decaying exponential.
%
% Inputs:
%    wvf     - The wavefront object
%    showbar - (Optional) Boolean indicating whether or not to show the
%              calculation wait bar
%
% Outputs:
%    wvf     - The wavefront object
%
% Optional key/value pairs:
%     'no lca'                             - If true, do not adjust
%                                            zcoeffs for LCA. Default
%                                            false.
%
% Notes:
%    * If the function is already computed and not stale, this will return
%      fast. Otherwise it computes and stores.
%
% See Also:
%    wvfCreate, wvfGet, wfvSet, wvfComputePSF
%

% History:
%    xx/xx/xx       Original code provided by Heidi Hofer.
%    xx/xx/11       (c) Wavefront Toolbox Team 2011, 2012
%    08/20/11  dhb  Rename function and pull out of supplied routine.
%                   Reformat comments.
%    09/05/11  dhb  Rewrite for wvf struct i/o. Rename.
%    05/29/12  dhb  Removed comments about old inputs, since this now gets
%                   its data via wvfGet.
%    06/04/12  dhb  Implement caching system.
%    07/23/12  dhb  Add in tip and tilt terms to be consistent with OSA
%                   standard. Verified that these just offset the position
%                   of the psf by a wavelength independent amount for the
%                   current calculation.
%    07/24/12  dhb  Switch sign of y coord to match OSA standard.
%    11/07/17  jnm  Comments & formatting
%    12/13/17  dhb  Redo definition of center position in grid to always
%                   have a sample at (0,0) in the pupil plane, and for this
%                   to match up with where Matlab likes this by convention.
%                   Improves stability of resutls wrt to even/odd support
%                   when sampling is a little coarse.
%    01/01/18  dhb  Consistency check to numerical precision.
%    01/18/18  jnm  Formatting update to match Wiki.
%    04/29/19  dhb  Add 'nolca' key/value pair and force lca values to zero
%                   in this case.
%    07/05/22  npc  Custom LCA

% Examples:
%{
	wvf = wvfCreate;
	wvf = wvfComputePupilFunction(wvf);
%}

%% Input parse
%
% Run ieParamFormat over varargin before passing to the parser,
% so that keys are put into standard format
p = inputParser;
p.addParameter('nolca',false,@islogical);
ieVarargin = ieParamFormat(varargin);
ieVarargin = wvfKeySynonyms(ieVarargin);
p.parse(ieVarargin{:});

%% Parameter checking
if notDefined('wvf'), error('wvf required'); end
if notDefined('showBar'), showBar = ieSessionGet('wait bar'); end

% Only do this if we need to. It might already be computed
if (~isfield(wvf, 'pupilfunc') || ~isfield(wvf, 'PUPILFUNCTION_STALE') ...
        || wvf.PUPILFUNCTION_STALE)
    
    % Make sure calculation pupil size is less than or equal to the pupil
    % size that gave rise to the measured coefficients.
    calcPupilSizeMM = wvfGet(wvf, 'calc pupil size', 'mm');
    measPupilSizeMM = wvfGet(wvf, 'measured pupil size', 'mm');
    if (calcPupilSizeMM > measPupilSizeMM)
        error(['Calculation pupil (%.2f mm) must not exceed measurement'...
            ' pupil (%.2f mm).'], calcPupilSizeMM, measPupilSizeMM);
    end
    
    % Handle defocus relative to reference wavelength.
    %
    % The defocus correction for the calculation is expressed as the
    % difference (diopters) between the defocus correction at measurement
    % time and the defocus correction for this calculatiion. This models
    % any lenses external to the observer's eye, which affect focus but not
    % the accommodative state.
    %
    % There are also calc and measured observer accommodation parameters,
    % which seem similar to these and I don't think are currently used.
    if (wvfGet(wvf, 'calcobserveraccommodation') ~= wvfGet(wvf, 'measuredobserveraccommodation'))
        error(['We do not currently know how to deal with values '...
            'that differ from measurement time']);
    end
            
    defocusCorrectionDiopters = ...
        wvfGet(wvf, 'calc observer focus correction') - ...
        wvfGet(wvf, 'measured observer focus correction');
    
    % Convert defocus from diopters to microns
    defocusCorrectionMicrons = wvfDefocusDioptersToMicrons(...
        defocusCorrectionDiopters, measPupilSizeMM);
    
    % Convert wavelengths in nanometers to wavelengths in microns
    waveUM = wvfGet(wvf, 'calc wavelengths', 'um');
    waveNM = wvfGet(wvf, 'calc wavelengths', 'nm');
    nWavelengths = wvfGet(wvf, 'number calc wavelengths');
    
    % Compute the pupil function
    %
    % This needs to be done separately at each wavelength because the size
    % in the pupil plane that we sample is wavelength dependent.
    if showBar, wBar = waitbar(0, 'Computing pupil functions'); end
    
    pupilfunc = cell(nWavelengths, 1);
    areapix = zeros(nWavelengths, 1);
    areapixapod = zeros(nWavelengths, 1);
    wavefrontaberrations = cell(nWavelengths, 1);
    
    % Check whether if we are using a custom LCA
    customLCAfunction = wvfGet(wvf, 'custom lca');

    for ii = 1:nWavelengths
        thisWave = waveNM(ii);
        if showBar
            waitbar(ii / nWavelengths, wBar, sprintf(...
                'Pupil function for %.0f', thisWave));
        end
        
        % Set SCE correction params, if desired
        xo  = wvfGet(wvf, 'scex0');
        yo  = wvfGet(wvf, 'scey0');
        rho = wvfGet(wvf, 'sce rho');
        
        % Set up pupil coordinates
        nPixels = wvfGet(wvf, 'spatial samples');
        pupilPlaneSizeMM = wvfGet(wvf, 'pupil plane size', 'mm', thisWave);
        pupilPos = (1:nPixels) - (floor(nPixels / 2) + 1);
        pupilPos = pupilPos * (pupilPlaneSizeMM / nPixels);
        
        % Do the meshgrid thing and flip y. Empirically the flip makes
        % things work out right.
        [xpos, ypos] = meshgrid(pupilPos);
        ypos = -ypos;
 
        % Set up the amplitude of the pupil function. This depends entirely
        % on the SCE correction. For x, y positions within the pupil, rho
        % is used to set the pupil function amplitude.
        if all(rho) == 0
            A = ones(nPixels, nPixels);
        else
            % Get the wavelength-specific value of rho for the
            % Stiles-Crawford effect.
            rho = wvfGet(wvf, 'sce rho', thisWave);
            
            % For the x, y positions within the pupil, the value of rho is
            % used to set the amplitude. I guess this is where the SCE
            % stuff matters. We should have a way to expose this for
            % teaching and in the code.
            A = 10 .^ (-rho * ((xpos - xo) .^ 2 + (ypos - yo) .^ 2));
        end
        
        % Compute longitudinal chromatic aberration (LCA) relative to
        % measurement wavelength and then convert to microns so that we can
        % add this in to the wavefront aberrations. The LCA is the
        % chromatic aberration of the human eye. It is encoded in the
        % function wvfLCAFromWavelengthDifference. 
        %
        % That function returns the difference in refractive power for this
        % wavelength relative to the measured wavelength (and there should
        % only be one, although there may be multiple calc wavelengths).
        %  
        % We flip the sign to describe change in optical power when we pass
        % this through wvfDefocusDioptersToMicrons.
        if (p.Results.nolca)
            lcaDiopters = 0;
            lcaMicrons = 0;
        else
            if (isempty(customLCAfunction))
                lcaDiopters = wvfLCAFromWavelengthDifference(wvfGet(wvf, ...
                    'measured wavelength', 'nm'), thisWave);
            else
                lcaDiopters = customLCAfunction(wvfGet(wvf, ...
                    'measured wavelength', 'nm'), thisWave);
            end
            lcaMicrons = wvfDefocusDioptersToMicrons(-lcaDiopters, ...
                measPupilSizeMM);
        end
        
        % The Zernike polynomials are defined over the unit disk. At
        % measurement time, the pupil was mapped onto the unit disk, so we
        % do the same normalization here to obtain the expansion over the
        % disk.
        %
        % And by convention expanding gives us the wavefront aberrations in
        % microns.
        norm_radius = (sqrt(xpos .^ 2 + ypos .^ 2)) / ...
            (measPupilSizeMM / 2);
        theta = atan2(ypos, xpos);
        norm_radius_index = norm_radius <= 1;
        
        % Get Zernike coefficients and add in appropriate info to defocus
        defocusZcoeffIndex = wvfOSAIndexToVectorIndex('defocus');

        % Need to make sure the c vector is long enough to contain defocus
        % term, because we handle that specially and it's easy just to make
        % sure it is there. This wastes a little time when we just compute
        % diffraction, but that is the least of our worries.
        c = wvfGet(wvf, 'zcoeffs');
        if (length(c) < defocusZcoeffIndex)
            c(length(c) + 1:defocusZcoeffIndex) = 0;
        end

        % Apply the defocus correction
        c(defocusZcoeffIndex) = c(defocusZcoeffIndex) + lcaMicrons + defocusCorrectionMicrons;
        
        % fprintf('At wavlength %0.1f nm, adding LCA of %0.3f microns to 
        % j = 4 (defocus) coefficient\n', thisWave, lcaMicrons); 
        
        % This loop uses the function zerfun to compute the Zernike
        % polynomial of each required order. That function normalizes a bit
        % differently than the OSA standard, with a factor of 1/sqrt(pi)
        % that is not part of the OSA definition. We correct by
        % multiplying by the same factor.
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
        
        % Set values outside the pupil we're calculating for to 0 amplitude
        pupilfuncphase(norm_radius > calcPupilSizeMM/measPupilSizeMM)=0;
        
        % Multiply phase by the pupil function amplitude function.
        % Important to zero out before this step, because computation of A
        % doesn't know about the pupil size.
        pupilfunc{ii} = A .* pupilfuncphase;
        % vcNewGraphWin; imagesc(angle(pupilfunc{ii}))
        
        % We think the ratio of these two quantities tells us how much
        % light is effectively lost in cone absorbtions because of the
        % Stiles-Crawford effect. They might as well be computed here, 
        % because they depend only on the pupil function and the sce params
        areapix(ii) = sum(sum(abs(pupilfuncphase)));
        areapixapod(ii) = sum(sum(abs(pupilfunc{ii})));
        
        % Area pix used to be computed in another way, check that we get
        % same answer.
        kindex = find(norm_radius <= calcPupilSizeMM / measPupilSizeMM);
        areapixcheck = numel(kindex);
        if (max(abs(areapix(ii) - areapixcheck)) > 1e-10)
            error('Two ways of computing areapix do not agree');
        end
    end
    
    if showBar, close(wBar); end
    
    wvf.wavefrontaberrations = wavefrontaberrations;
    wvf.pupilfunc = pupilfunc;
    wvf.areapix = areapix;
    wvf.areapixapod = areapixapod;
    
    % Let the rest of the code know we just computed the pupil function and
    % that a new PSF will be needed.
    wvf.PUPILFUNCTION_STALE = false;
    wvf.PSF_STALE = true;
    
end

end

% This is the old brute force code for doing the computation. The
% loop above is more elegant and flexible. This code can go away
% after we're comfortable the new code is working right. Note that
% this code does not expect the c array to contain piston, so the
% indexing is one off from what we now are using.
%
% 07/24/12 dhb  Checked the formula out to c(15) against OSA table and
%               didn't find any typos
% 11/07/17 jnm  changing this to a block comment for ease of access if
%               anything needs to be checked.
%{
wavefrontAberrationsUM = ...
0 + ...
c(1) .* 2 .* norm_radius .* sin(theta) + ...
c(2) .* 2 .* norm_radius .* cos(theta) + ...
c(3) .* sqrt(6) .* norm_radius .^ 2 .* sin(2 .* theta) + ...
c(4) .* sqrt(3) .* (2 .* norm_radius .^ 2 - 1) + ...
c(5) .* sqrt(6) .* norm_radius .^ 2 .* cos(2 .* theta) + ...
c(6) .* sqrt(8) .* norm_radius .^ 3 .* sin(3 .* theta) + ...
c(7) .* sqrt(8) .* (3 .* norm_radius .^ 3 - 2 .* norm_radius) .* ...
    sin(theta) + ...
c(8) .* sqrt(8) .* (3 .* norm_radius .^ 3 - 2 .* norm_radius) .* ...
    cos(theta) + ...
c(9) .* sqrt(8) .* norm_radius .^ 3 .* cos(3 .* theta) + ...
c(10) .* sqrt(10) .* norm_radius .^ 4 .* sin(4 .* theta) + ...
c(11) .* sqrt(10) .* (4 .* norm_radius .^ 4 - 3 .* norm_radius .^ 2) .* ...
    sin(2 .* theta) + ...
c(12) .* sqrt(5) .* (6 .* norm_radius .^ 4 - 6 .* norm_radius .^ 2 + 1) ...
    + ...
c(13) .* sqrt(10) .* (4 .* norm_radius .^ 4 - 3 .* norm_radius .^ 2) .* ...
    cos(2 .* theta) + ...
c(14) .* sqrt(10) .* norm_radius .^ 4 .* cos(4 .* theta) + ...
c(15) .* 2 .* sqrt(3) .* norm_radius .^ 5 .* sin(5 .* theta) + ...
c(20) .* 2 .* sqrt(3) .* norm_radius .^ 5 .* cos(5 .* theta) + ...
c(19) .* 2 .* sqrt(3) .* (5 .* norm_radius .^ 5 - 4 .* ...
    norm_radius .^ 3) .* cos(3 .* theta) + ...
c(16) .* 2 .* sqrt(3) .* (5 .* norm_radius .^ 5 - 4 .* ...
    norm_radius .^ 3) .* sin(3 .* theta) + ...
c(18) .* 2 .* sqrt(3) .* (10 .* norm_radius .^ 5 - 12 .* ...
    norm_radius .^ 3 + 3 .* norm_radius) .* cos(theta) + ...
c(17) .* 2 .* sqrt(3) .* (10 .* norm_radius .^ 5 - 12 .* ...
    norm_radius .^ 3 + 3 .* norm_radius) .* sin(theta) + ...
c(27) .* sqrt(14) .* norm_radius .^ 6 .* cos(6 .* theta) + ...
c(21) .* sqrt(14) .* norm_radius .^ 6 .* sin(6 .* theta) + ...
c(26) .* sqrt(14) .* (6 .* norm_radius .^ 6 - 5 .* norm_radius .^ 4) .* ...
    cos(4 .* theta) + ...
c(22) .* sqrt(14) .* (6 .* norm_radius .^ 6 - 5 .* norm_radius .^ 4) .* ...
    sin(4 .* theta) + ...
c(25) .* sqrt(14) .* (15 .* norm_radius .^ 6 - 20 .* norm_radius .^ 4 + ...
    6 .* norm_radius .^ 2) .* cos(2 .* theta) + ...
c(23) .* sqrt(14) .* (15 .* norm_radius .^ 6 - 20 .* norm_radius .^ 4 + ...
    6 .* norm_radius .^ 2) .* sin(2 .* theta) + ...
c(24) .* sqrt(7) .* (20 .* norm_radius .^ 6 - 30 .* norm_radius .^ 4 + ...
    12 .* norm_radius .^ 2 - 1) + ...
c(35) .* 4 .* norm_radius .^ 7 .* cos(7 .* theta) + ...
c(28) .* 4 .* norm_radius .^ 7 .* sin(7 .* theta) + ...
c(34) .* 4 .* (7 .* norm_radius .^ 7 - 6 .* norm_radius .^ 5) .* ...
    cos(5 .* theta) + ...
c(29) .* 4 .* (7 .* norm_radius .^ 7 - 6 .* norm_radius .^ 5) .* ...
    sin(5 .* theta) + ...
c(33) .* 4 .* (21 .* norm_radius .^ 7 - 30 .* norm_radius .^ 5 + 10 .* ...
    norm_radius .^ 3) .* cos(3 .* theta) + ...
c(30) .* 4 .* (21 .* norm_radius .^ 7 - 30 .* norm_radius .^ 5 + 10 .* ...
    norm_radius .^ 3) .* sin(3 .* theta) + ...
c(32) .* 4 .* (35 .* norm_radius .^ 7 - 60 .* norm_radius .^ 5 + 30 .* ...
    norm_radius .^ 3 - 4 .* norm_radius) .* cos(theta) + ...
c(31) .* 4 .* (35 .* norm_radius .^ 7 - 60 .* norm_radius .^ 5 + 30 .* ...
    norm_radius .^ 3 - 4 .* norm_radius) .* sin(theta) + ...
c(44) .* sqrt(18) .* norm_radius .^ 8 .* cos(8 .* theta) + ...
c(36) .* sqrt(18) .* norm_radius .^ 8 .* sin(8 .* theta) + ...
c(43) .* sqrt(18) .* (8 .* norm_radius .^ 8 - 7 .* norm_radius .^ 6) .* ...
    cos(6 .* theta) + ...
c(37) .* sqrt(18) .* (8 .* norm_radius .^ 8 - 7 .* norm_radius .^ 6) .* ...
    sin(6 .* theta) + ...
c(42) .* sqrt(18) .* (28 .* norm_radius .^ 8 - 42 .* norm_radius .^ 6 + ...
    15 .* norm_radius .^ 4) .* cos(4 .* theta) + ...
c(38) .* sqrt(18) .* (28 .* norm_radius .^ 8 - 42 .* norm_radius .^ 6 + ...
    15 .* norm_radius .^ 4) .* sin(4 .* theta) + ...
c(41) .* sqrt(18) .* (56 .* norm_radius .^ 8 - 105 .* norm_radius .^ 6 ...
    + 60 .* norm_radius .^ 4 - 10 .* norm_radius .^ 2) .* ...
    cos(2 .* theta) + ...
c(39) .* sqrt(18) .* (56 .* norm_radius .^ 8 - 105 .* norm_radius .^ 6 ...
    + 60 .* norm_radius .^ 4 - 10 .* norm_radius .^ 2) .* ...
    sin(2 .* theta) + ...
c(40) .* 3 .* (70 .* norm_radius .^ 8 - 140 .* norm_radius .^ 6 + 90 .* ...
    norm_radius .^ 4 - 20 .* norm_radius .^ 2 + 1) + ...
c(54) .* sqrt(20) .* norm_radius .^ 9 .* cos(9 .* theta) + ...
c(45) .* sqrt(20) .* norm_radius .^ 9 .* sin(9 .* theta) + ...
c(53) .* sqrt(20) .* (9 .* norm_radius .^ 9 - 8 .* norm_radius .^ 7) .* ...
    cos(7 .* theta) + ...
c(46) .* sqrt(20) .* (9 .* norm_radius .^ 9 - 8 .* norm_radius .^ 7) .* ...
    sin(7 .* theta) + ...
c(52) .* sqrt(20) .* (36 .* norm_radius .^ 9 - 56 .* norm_radius .^ 7 + ...
    21 .* norm_radius .^ 5) .* cos(5 .* theta) + ...
c(47) .* sqrt(20) .* (36 .* norm_radius .^ 9 - 56 .* norm_radius .^ 7 + ...
    21 .* norm_radius .^ 5) .* sin(5 .* theta) + ...
c(51) .* sqrt(20) .* (84 .* norm_radius .^ 9 - 168 .* ...
    norm_radius .^ 7 + 105 .* norm_radius .^ 5 - 20 .* ...
    norm_radius .^ 3) .* cos(3 .* theta) + ...
c(48) .* sqrt(20) .* (84 .* norm_radius .^ 9 - 168 .* ...
    norm_radius .^ 7 + 105 .* norm_radius .^ 5 - 20 .* ...
    norm_radius .^ 3) .* sin(3 .* theta) + ...
c(50) .* sqrt(20) .* (126 .* norm_radius .^ 9 - 280 .* ...
    norm_radius .^ 7 + 210 .* norm_radius .^ 5 - 60 .* ...
    norm_radius .^ 3 + 5 .* norm_radius) .* cos(theta) + ...
c(49) .* sqrt(20) .* (126 .* norm_radius .^ 9 - 280 .* ...
    norm_radius .^ 7 + 210 .* norm_radius .^ 5 - 60 .* ...
    norm_radius .^ 3 + 5 .* norm_radius) .* sin(theta) + ...
c(65) .* sqrt(22) .* norm_radius .^ 10 .* cos(10 .* theta) + ...
c(55) .* sqrt(22) .* norm_radius .^ 10 .* sin(10 .* theta) + ...
c(64) .* sqrt(22) .* (10 .* norm_radius .^ 10 - 9 .* ...
    norm_radius .^ 8) .* cos(8 .* theta) + ...
c(56) .* sqrt(22) .* (10 .* norm_radius .^ 10 - 9 .* ...
    norm_radius .^ 8) .* sin(8 .* theta) + ...
c(63) .* sqrt(22) .* (45 .* norm_radius .^ 10 - 72 .* ...
    norm_radius .^ 8 + 28 .* norm_radius .^ 6) .* cos(6 .* theta) + ...
c(57) .* sqrt(22) .* (45 .* norm_radius .^ 10 - 72 .* ...
    norm_radius .^ 8 + 28 .* norm_radius .^ 6) .* sin(6 .* theta) + ...
c(62) .* sqrt(22) .* (120 .* norm_radius .^ 10 - 252 .* ...
    norm_radius .^ 8 + 168 .* norm_radius .^ 6 - 35 .* ...
    norm_radius .^ 4) .* cos(4 .* theta) + ...
c(58) .* sqrt(22) .* (120 .* norm_radius .^ 10 - 252 .* ...
    norm_radius .^ 8 + 168 .* norm_radius .^ 6 - 35 .* ...
    norm_radius .^ 4) .* sin(4 .* theta) + ...
c(61) .* sqrt(22) .* (210 .* norm_radius .^ 10 - 504 .* ...
    norm_radius .^ 8 + 420 .* norm_radius .^ 6 - 140 .* ...
    norm_radius .^ 4 + 15 .* ...
    norm_radius .^ 2) .* cos(2 .* theta) + ...
c(59) .* sqrt(22) .* (210 .* norm_radius .^ 10 - 504 .* ...
    norm_radius .^ 8 + 420 .* norm_radius .^ 6 - 140 .* ...
    norm_radius .^ 4 + 15 .* norm_radius .^ 2) .* sin(2 .* theta) + ...
c(60) .* sqrt(11) .* (252 .* norm_radius .^ 10 - 630 .* ...
    norm_radius .^ 8 + 560 .* norm_radius .^ 6 - 210 .* ...
    norm_radius .^ 4 + 30 .* norm_radius .^ 2 - 1);
%}
