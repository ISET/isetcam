function wvf = wvfComputePupilFunction(wvf, varargin)
% Compute the pupil fuction given the wvf for the human eye case
%
% Syntax:
%   wvf = wvfComputePupilFunction(wvf, varargin)
%
% Description:
%    This version of the pupil function calculation is designed for
%    the human eye calculations starting in ISETBio.  We are
%    it for generalization as we integrate into ISETCam.
%
%    The pupil function is a complex number that represents the amplitude
%    and phase of the wavefront across the pupil. The pupil function at a
%    specific wavelength is
%
%       pupilF = A exp(-1i 2 pi (phase/wavelength));
%
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
%
% Optional key/value pairs:
%      humanlca   - If true, apply human longitudinal chromatic aberration.
%                   Default: False
%      lcafunction - Use this vector as the longitudinal chromatic
%                    aberration in diopters
%      aperture    - A matrix for the aperture function
%      computesce  - Apply the Stiles Crawford affect to the aperture
%                    function
%
% Outputs:
%    wvf     - The wavefront object
%
% See Also:
%    wvfCompute, wvfComputePSF, wvfCreate, wvfGet, wfvSet
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
%    07/05/23  baw  Many.  Changed nolca to lca, removed big 'if'

% Examples:
%{
 % This example could be improved, or at least produce more
 % interesting plots, if we put in some actual Zernike values,
 % so it wouldn't just be uniform.
 wvf = wvfCreate('lca method','human');
 wvf = wvfComputePupilFunction(wvf);
 ieNewGraphWin;
 subplot(1,2,1); imagesc(wvfGet(wvf,'pupil function phase')); axis('square');
 subplot(1,2,2); imagesc(wvfGet(wvf,'aperture')); axis('square');
%}

%% Input parse

% Run ieParamFormat over varargin to put key/val args into standard format
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('wvf',@isstruct);

%p.addParameter('humanlca',false,@islogical);   % Apply longitudinal chromatic aberration
%p.addParameter('lcafunction',[],@ismatrix);
p.addParameter('aperture',[],@ismatrix);
p.addParameter('computesce',false,@islogical);   % Apply Stiles Crawford effect to aperture function

varargin = wvfKeySynonyms(varargin);

p.parse(wvf,varargin{:});

%% Parameter checking

% Make sure calculation pupil size is less than or equal to the pupil
% size that gave rise to the measured coefficients.
calcPupilSizeMM = wvfGet(wvf, 'calc pupil diameter', 'mm');
measPupilSizeMM = wvfGet(wvf, 'measured pupil diameter', 'mm');
if (abs(calcPupilSizeMM - measPupilSizeMM) > 1e-6)
    error(['Calculation pupil (%.2f mm) must not exceed measurement'...
        ' pupil (%.2f mm).'], calcPupilSizeMM, measPupilSizeMM);
end

%{
% Also not sure this is necessary.
%
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

% The original Hofer code allowed that the observer we model might
% have had a different focus from the observer we measured.  This
% defocus correction is included here and added later.
%
% July 2023, BW thought this was not relevant to our code and
% commented it out.
defocusCorrectionDiopters = ...
    wvfGet(wvf, 'calc observer focus correction') - ...
    wvfGet(wvf, 'measured observer focus correction');

% Convert defocus from diopters to microns
defocusCorrectionMicrons = wvfDefocusDioptersToMicrons(...
    defocusCorrectionDiopters, measPupilSizeMM);
%}

% Convert wavelengths in nanometers to wavelengths in microns
waveUM = wvfGet(wvf, 'calc wavelengths', 'um');
waveNM = wvfGet(wvf, 'calc wavelengths', 'nm');
nWavelengths = wvfGet(wvf, 'number calc wavelengths');

% Compute the pupil function
%
% This needs to be done separately at each wavelength because the size
% in the pupil plane that we sample is wavelength dependent.
pupilfunc = cell(nWavelengths, 1);
areapix = zeros(nWavelengths, 1);
areapixapod = zeros(nWavelengths, 1);
wavefrontaberrations = cell(nWavelengths, 1);

% Check whether if we are using a custom LCA
% customLCAfunction = wvfGet(wvf, 'lca method');

for ii = 1:nWavelengths
    thisWave = waveNM(ii);
    
    % Set up pupil coordinates
    %{
    % BW: July, 2023
    % The code in this block works.  But I edited it, using wvfGet, to clarify.
    % This also brought to my attention some issues in the different
    % calls to wvfGet that are still a work in progress.  See wvfGet
    % notes about 'ref' and 'calc' and 'meas'.
    %
    nPixels = wvfGet(wvf, 'spatial samples');
    pupilPlaneSizeMM = wvfGet(wvf, 'pupil plane size', 'mm', thisWave);
    pupilPos = (1:nPixels) - (floor(nPixels / 2) + 1);
    dx = (pupilPlaneSizeMM / nPixels);
    pupilPos = pupilPos * dx;
    %}
    % refSizeOfFieldMM
    pupilPos = wvfGet(wvf,'pupil positions',thisWave,'mm');
    
    %{
    nPixels = wvfGet(wvf, 'number spatial samples');
    pupilPos = (1:nPixels) - wvfGet(wvf,'middle row');
    dx = wvfGet(wvf,'pupil sample spacing','mm',thisWave);
    pupilPos = pupilPos * dx;
    %}

    % Do the meshgrid thing and flip y. Empirically the flip makes
    % things work out right.
    [xpos, ypos] = meshgrid(pupilPos);
    ypos = -ypos;

    % The Zernike polynomials are defined over the unit disk. We treat the
    % measured pupil size as the unit disk. The normalized radius is
    % calculated by dividing distance from the center by the measured pupil
    % radius (measPupilSizeMM/2)
    norm_radius = (sqrt(xpos .^ 2 + ypos .^ 2)) / (measPupilSizeMM / 2);
    theta = atan2(ypos, xpos);
    % ieNewGraphWin; imagesc(norm_radius); axis square

    % Only values that are within the unit circle are valid for the
    % Zernike polynomial.
    norm_radius_index = (norm_radius <= 1);
    % ieNewGraphWin; imagesc(pupilPos,pupilPos,norm_radius_index); axis image   

    %% The aperture function calculations

    % In the original code, only the Stiles Crawford Effect (SCE) was
    % implemented.  This code allows for a general aperture function, which
    % is crucial for calculation flare.
    nPixels = wvfGet(wvf, 'number spatial samples');
    if isempty(p.Results.aperture)
        % Assume the aperture is all 1's.
        aperture = ones(nPixels, nPixels);
    else
        % Use the passed in aperture function. Make sure its pixel
        % count matches nPixels.
        aperture = p.Results.aperture;
        if ~isequal(size(aperture),[nPixels,nPixels])
            % warning('Adjusting aperture function size.');
            aperture = imresize(aperture,[nPixels,nPixels]);
            aperture(aperture > 1) = 1;
            aperture(aperture < 0) = 0;
        end
    end
    % ieNewGraphWin; imagesc(aperture); axis square

    % This index has the locations of the calculated pupil values.  Values
    % outside this region will be set to 0.
    calc_radius = calcPupilSizeMM/measPupilSizeMM;
    calc_radius_index = (norm_radius < calc_radius);

    % We size the aperture function to be within the region
    % defined by the calculated pupil diameter.  
    boundingBox = imageBoundingBox(calc_radius_index);

    % Resize the aperture mask to the bounding box of the calculated
    % radius.  Using nearest neighbor interpolation fixes problems
    % caused by linear interpolation, where when we start with a mask of
    % all ones it ends up with some intermediate values.  It is possible
    % that nearest neighbor is not as desirable when there is a real space
    % varying pupil aperture mask passed.
    aperture = imresize(aperture,[boundingBox(3),boundingBox(4)],'nearest');
   
    % Extend with zeros outside of the calcpupil radius.
    % DHB/BAW: We subtract 1 to pad a little less. This leaves the pupil as a circle
    % in the case we looked at, and causes this code to match better the old
    % ISETBio master when no aperture is passed. There is an issue with
    % s_wvfDiffraction but it doesn't seem to be affected by this change of
    % subracting 1.
    %
    % We might come back and carefully comment all this new code someday,
    % as well as look more closely at s_wvfDiffraction.
    sz = double(round((nPixels - boundingBox(3))/2) - 2);
    if sz > 0
        % In some cases, there is no need to pad.
        aperture = padarray(aperture,[sz,sz],0,'both');
    end
    aperture = imresize(aperture,[nPixels,nPixels],'nearest');
    
    % ieNewGraphWin; imagesc(pupilPos,pupilPos,aperture); axis image    

    % Keep the amplitude within bounds. imresize, with some interpolation,
    % functions, produce values outside 0,1.  With bilinear we have not
    % observed this behavior.
    %
    % If there are no observed warnings after July 14, delete this
    % section of code.
    if max(aperture(:)) > 1, warning('>1'); end
    if min(aperture(:)) < 0, warning('<0'); end

    aperture(aperture > 1) = 1;
    aperture(aperture < 0) = 0;

    % ieNewGraphWin; imagesc(pupilPos,pupilPos,aperture); axis image    
    
    if p.Results.computesce
        % Incorporate the SCE correction params.  Modify the aperture
        % function.

        % Get the wavelength-specific value of rho for the
        % Stiles-Crawford effect.
        rho = wvfGet(wvf, 'sce rho', thisWave);
        xo  = wvfGet(wvf, 'scex0');
        yo  = wvfGet(wvf, 'scey0');

        % For the x, y positions within the pupil, the value of rho is
        % used to set the amplitude. I guess this is where the SCE
        % stuff matters. We should have a way to expose this for
        % teaching and in the code.
        sceFunc = 10 .^ (-rho * ((xpos - xo) .^ 2 + (ypos - yo) .^ 2));
        aperture = aperture .* sceFunc;
    end

    % Finally, set the aperture values outside the pupil to be 0.
    aperture(norm_radius > calcPupilSizeMM/measPupilSizeMM) = 0;

    %% The pupil phase calculations

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
    lcaMethod = wvfGet(wvf,'lcaMethod');
    if (ischar(lcaMethod) & strcmp(lcaMethod,'human'))
        % disp('Using human LCA wvfLCAFromWave...')
        lcaDiopters = wvfLCAFromWavelengthDifference(wvfGet(wvf, ...
            'measured wavelength', 'nm'), thisWave);
        lcaMicrons = wvfDefocusDioptersToMicrons(-lcaDiopters, ...
            measPupilSizeMM);
    elseif (ischar(lcaMethod) & strcmp(lcaMethod,'none'))
        % No longitudinal chromatic aberration.  If we have only one
        % wavelength, perhaps we should not include chromatic
        % aberration.  But maybe we should, say for the human case?
        % disp('No LCA.')

        % The diopters is normally translated into microns, below.
        % So specificying lcaMicrons is enough, no need for
        % lcaDiopters.
        %
        lcaMicrons = 0;
    elseif (ismatrix(lcaMethod))
        % disp('Using a custom LCA...')
        %
        % Needs to be written.  I think lcaDiopters should be obtained from
        % the matrix lcaFunction in some way, but need to determine
        % convention.  But it also looks like we once had the idea of
        % passing an actual function.
        %         lcaDiopters = customLCAfunction(wvfGet(wvf, ...
        %             'measured wavelength', 'nm'), thisWave);
        error('Need to implement lca argument is a vector or matrix case.');
        % Something like this
        lcaDiopters = lcaFunction;
        lcaMicrons = wvfDefocusDioptersToMicrons(-lcaDiopters, ...
            measPupilSizeMM);
    elseif isa(lcaMethod,'function_handle')
        % We need to calculate lcaMicrons for each wavelength, I think.
        error('Need to implement lca argument is a function handle case.');
        % Something like this
        wave = wvfGet(wvf,'wave');
        measuredw = wvfGet(wvf, 'measured wavelength');
        measuredp = wvfGet(wvf,'measured pupil size','mm')
        for ww = 1:numel(wave)
            lcaDiopters = lcaFunction(measuredw,wave(ww));
            lcaMicrons = wvfDefocusDioptersToMicrons(-lcaDiopters, ...
                measPupilSizeMM);
        end

    else
        error('Unexpected value for custom lca field in wvf');
    end
    
    % Get Zernike coefficients
    % Need to make sure the c vector is long enough to contain defocus
    % term, because we handle that specially so we can add in LCA with
    % there actually being something there.
    % 
    % This wastes a little time when we just compute diffraction, but
    % that is the least of our worries.
    c = wvfGet(wvf, 'zcoeffs');
    if (length(c) < 5)
        c(length(c) + 1:5) = 0;
    end
    c(5) = c(5) + lcaMicrons;

    % By convention the Zernikes specify the wavefront aberrations in
    % microns.
    %
    % We use the zernfun() to compute the Zernike polynomial of each
    % required order. That function normalizes a bit differently than the
    % OSA standard.  It has a factor, 1/sqrt(pi), that is not part of the
    % OSA definition. We correct for that factor, multiplying by sqrt(pi).
    %
    % Also, we do not bother to compute for coefficients that are 0.
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

    % This is the phase of the pupil function
    wavefrontaberrations{ii} = wavefrontAberrationsUM;
    pupilfuncphase = exp(-1i * 2 * pi * wavefrontAberrationsUM / waveUM(ii));

    % Set values outside the calc pupil diameter to zero.
    %
    % Conceptually, the aperture function should do this job, we
    % should not do it this way. Using the aperture is better
    % because this imposes an implicit circular aperture. 
    pupilfuncphase(norm_radius > calcPupilSizeMM/measPupilSizeMM) = 0;

    % Create the pupil function, combining the aperture and pupil phase
    % functions. 
    pupilfunc{ii} = aperture .* pupilfuncphase;
    %pupilfunc{ii} = pupilfuncphase;
    %{
     ieNewGraphWin; imagesc(pupilPos,pupilPos,aperture); axis image
     ieNewGraphWin; imagesc(pupilPos,pupilPos,angle(pupilfuncphase)); axis image
     ieNewGraphWin; imagesc(pupilPos,pupilPos,abs(pupilfuncphase)); axis image
    %}
    %{
     ieNewGraphWin; imagesc(pupilPos,pupilPos,abs(pupilfunc{ii})); axis image
     ieNewGraphWin; imagesc(pupilPos,pupilPos,angle(pupilfunc{ii})); axis image
    %}
    
    % These are special parameters Heidi Hofer calculated.  We do not
    % use them yet in ISETCam because, well, we don't really
    % understand them.
    %
    % We think the ratio of these two quantities tells us how much
    % light is lost in cone absorbtions because of the Stiles-Crawford
    % effect. They might as well be computed here, because they depend
    % only on the pupil function and the sce params
    areapix(ii) = sum(sum(abs(pupilfuncphase)));
    areapixapod(ii) = sum(sum(abs(pupilfunc{ii})));

    %{ 
    % BW:  July 2023
    % We haven't had an error here in years.
    % Area pix used to be computed in another way, check that we get
    % same answer.
    kindex = find(norm_radius <= calcPupilSizeMM / measPupilSizeMM);
    areapixcheck = numel(kindex);
    if (max(abs(areapix(ii) - areapixcheck)) > 1e-10)
        error('Two ways of computing areapix do not agree');
    end
    %}
end

% We think the aberrations are in microns (BW).    But look at
% t_wvfWatsonJOV for a comparison and some concern.
wvf.wavefrontaberrations = wavefrontaberrations;
wvf.pupilfunc = pupilfunc;
wvf.areapix = areapix;
wvf.areapixapod = areapixapod;

% Let the rest of the code know we just computed the pupil function and
% that a new PSF will be needed.
wvf.PUPILFUNCTION_STALE = false;

% The pupil function was recomputed; the PSF must be stale.
wvf.PSF_STALE = true;

end

