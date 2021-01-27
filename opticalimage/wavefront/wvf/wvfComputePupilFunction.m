function wvf = wvfComputePupilFunction(wvf, showBar)
% Compute the pupil fuction given the wvf object.
%
%    wvf = wvfComputePupilFunction(wvf)
%
% The pupil function is a complex number that represents the amplitude and
% phase of the wavefront across the pupil.  The pupil function at a
% specific wavelength is
%
%    pupilF = A exp(-1i 2 pi (phase/wavelength));
%
% The amplitude, A, is set to 1 here.  The name for the amplitude is XXX (I
% forget) and we should be able to adjust it in the future.  
%
% The pupil function is related to the PSF by the Fourier transform. See J.
% Goodman, Intro to Fourier Optics, 3rd ed, p. 131. (MDL)  This is computed
% in the wvf2PSF function, not here.
%
% The pupil function is calculated for 10 orders of Zernike coefficients
% specified to the OSA standard, with the convention that we assume that
% the coefficient for j = 0 is 0, and that the first entry of the passed
% coefficients corresponds to j = 1.  Adding in the j = 0 term does not
% change the psf.  The spatial coordinate system is also OSA standard.
%
% Note that this system is the same for both left and right eyes. If the
% biology is left-right reflection symmetric, one might want to left-right
% flip the coordinates when computing for the left eye (see OSA document).
%
% Original code provided by Heidi Hofer.
% (c) Wavefront Toolbox Team 2011, 2012
% Heavily modified for use in ISETCam, 2015
%
% Example:
%    wvf = wvfCreate;
%    wvf = wvfComputePupilFunction(wvf);
%
% See also: 
%  wvfCreate, wvfGet, wfvSet, wvfComputePSF

%% Parameter checking
if notDefined('wvf'), error('wvf required'); end
if notDefined('showBar'), showBar = ieSessionGet('wait bar'); end

% Only do this if we need to. It might already be computed

% Make sure calculation pupil size is less than or equal to the pupil
% size that gave rise to the measured coefficients.
pupilSizeMM = wvfGet(wvf,'pupil size','mm');

% Convert wavelengths in nanometers to wavelengths in microns
waveUM = wvfGet(wvf,'wavelengths','um');
waveNM = wvfGet(wvf,'wavelengths','nm');
nWavelengths = wvfGet(wvf,'n wave');

% Compute the pupil function
%
% This needs to be done separately at each wavelength because the size
% in the pupil plane that we sample is wavelength dependent.
if showBar, wBar = waitbar(0,'Computing pupil functions'); end

pupilfunc   = cell(nWavelengths,1);
% areapix     = zeros(nWavelengths,1);
% areapixapod = zeros(nWavelengths,1);
wavefrontaberrations = cell(nWavelengths,1);

for ii=1:nWavelengths
    thisWave = waveNM(ii);
    if showBar
        waitbar(ii/nWavelengths,wBar,sprintf('Pupil function for %.0f',thisWave));
    end
       
    %{
    % Set up pupil coordinates
    %
    % 3/9/2012, MDL: Removed nested for-loop for calculating the
    % SCE. Note previous code had x as rows of matrix, y as columns of
    % matrix. This has been changed so that x is columns, y is rows.
    %
    % 7/24/12, DHB: The above change produces a change of the
    % orientation of the pupil function/psf relative to  Heidi's
    % original code. I think Heidi's was not right.  But we also need
    % to flip the y coordinate, so that positive values go up in the
    % image.  I did this and I think it now matches Figure 7 of the OSA
    % Zernike standards document.  Also, doing this makes my pictures
    % of the PSF approximately match the orientation in Figure 4b in
    % Autrussea et al. 2011.
    nPixels = wvfGet(wvf,'spatial samples');
    pupilPlaneSizeMM = wvfGet(wvf,'pupil plane size','mm',thisWave);
    pupilPos = (0:(nPixels-1))*(pupilPlaneSizeMM/nPixels)-pupilPlaneSizeMM/2;
    [xpos, ypos] = meshgrid(pupilPos);
    ypos = ypos(end:-1:1,:);
    %}
    
    % Set up pupil coordinates.  Changed the commented code above to this
    % in order to match ISETBio exactly.
    nPixels = wvfGet(wvf, 'spatial samples');
    pupilPlaneSizeMM = wvfGet(wvf, 'pupil plane size', 'mm', thisWave);
    pupilPos = (1:nPixels) - (floor(nPixels / 2) + 1);
    pupilPos = pupilPos * (pupilPlaneSizeMM / nPixels);
    
    % Do the meshgrid thing and flip y. Empirically the flip makes
    % things work out right.
    [xpos, ypos] = meshgrid(pupilPos);
    ypos = -ypos;
    
    % This scalar could be passed in and adjusted for experiments.  Just
    % not yet.  Someone remind me of the name of this term, please!
    % (Apodization).
    A = ones(nPixels,nPixels);

    % Compute longitudinal chromatic aberration (LCA) relative to
    % measurement wavelength and then convert to microns so that we can
    % add this in to the wavefront aberrations.  The LCA is the
    % chromatic aberration of the human eye.  It is encoded in the
    % function wvfLCAFromWavelengthDifference.
    %
    % That function returns the difference in refractive power for this
    % wavelength relative to the measured wavelength (and there should
    % only be one, although there may be multiple calc wavelengths).
    %
    
    % There may be a difference between the wavelength we used to obtain
    % the Z coefficients and the one we are using to calculate. For the
    % human case, we know how much the defocus should change.  In general,
    % we do not.  So the code here is commented out and we are assuming
    % that the zcoeffs are adequate for the wls (wavelength we are using
    % for the calculation).  See the code in ISETBio if you would like to
    % make a weaker assumption and account for the system in ISETCam.
    %{
    lcaDiopters = wvfLCAFromWavelengthDifference(wvfGet(wvf,'zwavelength','nm'),thisWave);
    lcaMicrons  = wvfDefocusDioptersToMicrons(-lcaDiopters,measPupilSizeMM);
    %}
    
    % **********
    % In ISETBio the measured pupil size and the calculation pupil size can
    % differ.  In ISETCam, the measured and calculation pupil sizes are
    % always the same.  That is, when we get a set of Zernike coefficients
    % they always apply to the pupil size in the wvf structure.  This
    % limits the generalization, but greatly simplifies a lot of the code.
    % This comment should appear in a clearer and better place.
    %
    % Because of this, the ISETCam code should only match the ISETBio code
    % when the measured pupil size equals the calculation pupil size.
    % **********
    %
    % The Zernike polynomials are defined over the unit disk.  At
    % measurement time, the pupil was mapped onto the unit disk, so we
    % do the same normalization here to obtain the expansion over the
    % disk. 
    %
    % And by convention expanding gives us the wavefront aberrations in
    % microns.
    zpupilDiameterMM = wvfGet(wvf,'z pupil diameter');
    norm_radius = (sqrt(xpos.^2+ypos.^2))/(zpupilDiameterMM/2);
    theta = atan2(ypos,xpos);
    norm_radius_index = norm_radius <= 1;
   
    % Get Zernike coefficients and add in appropriate info to defocus
    % Need to make sure the c vector is long enough to contain defocus
    % term, because we handle that specially and it's easy just to make
    % sure it is there.  This wastes a little time when we just compute
    % diffraction, but that is the least of our worries.
    c = wvfGet(wvf,'zcoeffs');
    if (length(c) < 5),  c(length(c)+1:5) = 0; end
    % We don't defocus for human chromatic aberration in ISET 
    % c(5) = c(5) + lcaMicrons + defocusCorrectionMicrons;
    
    % fprintf('At wavlength %0.1f nm, adding LCA of %0.3f microns to j = 4 (defocus) coefficient\n',thisWave,lcaMicrons);
    
    % This loop uses the function zerfun to compute the Zernike
    % polynomial of each required order. That function normalizes a bit
    % differently than the OSA standard, with a factor of 1/sqrt(pi)
    % that is not part of the OSA definition.  We correct by
    % multiplying by the same factor.
    %
    % Also, we speed this up by not bothering to compute for c entries
    % that are 0.
    wavefrontAberrationsUM = zeros(size(xpos));
    for k = 1:length(c)
        if (c(k) ~= 0)
            osaIndex = k-1;
            [n,m] = wvfOSAIndexToZernikeNM(osaIndex);
            wavefrontAberrationsUM(norm_radius_index) =  ...
                wavefrontAberrationsUM(norm_radius_index) + ...
                c(k)*sqrt(pi)*zernfun(n,m,norm_radius(norm_radius_index),...
                theta(norm_radius_index),'norm');
        end
    end
    
    % Here is the phase of the pupil function, with unit amplitude
    % everywhere
    wavefrontaberrations{ii} = wavefrontAberrationsUM;
    pupilfuncphase = exp(-1i * 2 * pi * wavefrontAberrationsUM/waveUM(ii));
    
    % Set values outside the pupil we're calculating for to 0 amplitude
    % In ISETBio case there is a measurement size that can differ from the
    % calculation size.  But in ISETCam the calculated and measured are
    % always the same.
    pupilfuncphase(norm_radius > pupilSizeMM/zpupilDiameterMM)=0;
    
    % Multiply phase by the pupil function amplitude function.
    % Important to zero out before this step, because computation of A
    % doesn't know about the pupil size.
    pupilfunc{ii} = A.*pupilfuncphase;
    % vcNewGraphWin; imagesc(angle(pupilfunc{ii}))
end

if showBar, close(wBar); end

wvf.wavefrontaberrations = wavefrontaberrations;
wvf.pupilfunc = pupilfunc;


end


