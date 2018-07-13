function wvf = wvfFminPupilFunction(wvf, showBar)
% Edited from wvfComputePupilFunction to produce a version for
% fminsearchs
%
%    wvf = wvfFminPupilFunction(wvf,[showBar])
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
%
% See also: wvfCreate, wvfGet, wfvSet, wvfComputePSF
%
% Example:
%    wvf = wvfCreate;
%    wvf = wvfComputePupilFunction(wvf);
%
% Original code provided by Heidi Hofer.
%
% 8/20/11 dhb      Rename function and pull out of supplied routine.
%                  Reformat comments.
% 9/5/11  dhb      Rewrite for wvf struct i/o.  Rename.
% 5/29/12 dhb      Removed comments about old inputs, since this now gets
%                  its data via wvfGet.
% 6/4/12  dhb      Implement caching system.
% 7/23/12 dhb      Add in tip and tilt terms to be consistent with OSA standard.
%                  Verified that these just offset the position of the psf by
%                  a wavelength independent amount for the current calculation.
% 7/24/12 dhb      Switch sign of y coord to match OSA standard.
%
% (c) Wavefront Toolbox Team 2011, 2012
% Heavily modified for use in ISET, 2015

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
    
    % Deleted in ISET
    % We flip the sign to describe change in optical power when we pass
    % this through wvfDefocusDioptersToMicrons.
    %     lcaDiopters = wvfLCAFromWavelengthDifference(wvfGet(wvf,'measured wavelength','nm'),thisWave);
    %     lcaMicrons = wvfDefocusDioptersToMicrons(-lcaDiopters,measPupilSizeMM);

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
                c(k)*sqrt(pi)*zernfun(n,m,norm_radius(norm_radius_index),theta(norm_radius_index),'norm');
        end
    end
    
    % Here is the phase of the pupil function, with unit amplitude
    % everywhere
    wavefrontaberrations{ii} = wavefrontAberrationsUM;
    pupilfuncphase = exp(-1i * 2 * pi * wavefrontAberrationsUM/waveUM(ii));
    
    % Set values outside the pupil we're calculating for to 0 amplitude
    pupilfuncphase(norm_radius > pupilSizeMM/pupilPlaneSizeMM)=0;
    
    % Multiply phase by the pupil function amplitude function.
    % Important to zero out before this step, because computation of A
    % doesn't know about the pupil size.
    pupilfunc{ii} = A.*pupilfuncphase;
    % imagesc(angle(pupilfunc{ii}))
end

if showBar, close(wBar); end

wvf.wavefrontaberrations = wavefrontaberrations;
wvf.pupilfunc = pupilfunc;


end


