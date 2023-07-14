function wvfParams = wvfComputeOptimizedPSF(wvfParams)
% Optimize the PSF at a specified wavelength
%
% Syntax:
%   wvfParams = wvfComputeOptimizedPSF(wvfParams)
%
% Description:
%    Optimize the PSF seen at a specified wavelength. Optimization is
%    performed on the defocus parameter, relative to a specified nominal
%    focus wavelength. The full polychromatic PSF is returned at the list
%    of specified wavelengths.
%
%    This is implemented as a call into wvfComputeOptimzedConePSF.
%
% Inputs:
%    wvfParams - Wavefront structure. The required fields for the structure
%                (see comment in wvfComputePupilFunction for more details)
%       criterionFraction - The figure of merit is the radius of a centered
%                           and circularly averaged version of the psf that
%                           contains the specified criterionFraction of the
%                           total mass of the PSF seen by each cone. The
%                           smaller this radius, the better.
%       optimizeWl        - Wavelenght to optimize for.
%       wls               - Column vector of wavelengths over which
%                           polychromatic psf is computed.
%       zcoeffs           - Zernike coefficients.
%       measpupilMM       - Size of the pupil characterized by the
%                           coefficients, in MM.
%       caclpupilsize     - Size over which the returned pupil function is
%                           calculated, in MM.
%       wls               - The column vector of wavelengths over which to
%                           compute, in NANOMETERS.
%       nominalFocusWl    - Wavelength (in nm) of nominal focus.
%       defocusDiopters   - Defocus to add in (signed), in diopters.
%       fieldSampleSizeMMperPixel
%                         - Size in mm of each pixel of the pupil function.
%       sizeOfFieldMM     - The size of the square image over which the
%                           pupil function is computed in MM.
%
% Outputs:
%    wvfParams - The altered wavefront structure
%
% Optional key/value pairs:
%    These are fields that are optional for the wvfParams input struct.
%       conepsf           - Calcuated psf for each cone in T_cones, third
%                           dimension indexes cone type.
%       defocusDiopters   - The defocus added in to optimize.
%       coneSceFrac       - The vector with calculated SCE fraction for
%                           each cone type.
%       psf               - Calcuated polychromatic psf. Third dimension of
%                           returned matrix indexes wavelength.
%       pupilfunc         - Calculated pupil function. Third dimension of
%                           returned matrix indexes wavelength
%       arcminperpix      - Arc minutes per pixel for returned psfs.
%       strehl            - Strehl ratio of psf at each wavelength. If SCE
%                           correction is specified, the returned
%                         - strehl ratio is to the diffraction limited psf
%                           with the same SCE assumed.
%       sceFrac           - Fraction of light actually absorbed when SCE is
%                           taken into account, at each wavelength.
%       areapix           - Number of pixels within the computed pupil
%                           aperture at each wavelength
%       areapixapod       - Number of pixels within the computed pupil
%                           aperture at each wavelength, 
%                         - multiplied by the Stiles-Crawford aopdization.
%       defocusMicrons    - Defocus added in to zcoeffs(4) at each
%                           wavelength, in microns.
%
% Notes:
%    * [NOTE: DHB - This function is under development. The idea is that
%       the amound of defocus that produces the best PSF, at a particular
%       wavelength, is not determined trivially and is best found via
%       numerical optimization. We may never need this, and certainly don't
%       need it right now. I am moving to an "underDevelopment_wavefront"
%       directory and putting in an error message at the top so that people
%       don't think it might work.]
%    * [NOTE: JNM - The example is broken, but at least 'semi-present' now]
%

% History:
%    09/09/11  dhb  Wrote it.
%    11/13/17  jnm  Comments, example & formatting

% Examples:
%{
    % [Note: JNM - Please note that this example is broken, but as close as
    % I could get...]
    wvf0 = wvfCreate;
    wls = SToWls([400 10 31]);
    wvf0.coneWeights = [1 1 0];
    wvf0.criterionFraction = 0.9;
    wvf0.optimizeW1 = [480 500];

    load('T_cones_ss2');
    conePsfInfo.S = S_cones_ss2;
    conePsfInfo.T = T_cones_ss2;
    conePsfInfo.spdWeighting = ones(conePsfInfo.S(3),1);

    wvf0 = wvfSet(wvf0,'calc cone psf info',conePsfInfo);
    wvf0 = wvfComputePSF(wvf0);
    wvf0 = wvfComputeOptimizedConePSF(wvf0);
%}

%% This is not yet working.
error('This function is under development and not yet working');

index = find(wvfParams.optimizeWl == wvfParams.wls);
if (isempty(index))
    error(['Desired wavelength to optimize for not inluded in '...
        'wavelengths to compute for.']);
end

% Set up the fields we need in order to make wvfComputeOptimizedConePSF do
% what we want.
wvfParams.coneWeights = 1;
wvfParams.T_cones = zeros(1, length(wvfParams.wls));
wvfParams.T_cones(index) = 1;
wvfParams.weightingSpectrum = zeros(length(wvfParams.wls), 1);
wvfParams.weightingSpectrum(index) = 1;

% Do the work
wvfParams = wvfComputeOptimizedConePSF(wvfParams);

% Remove the fields we added in and no longer need
wvfParams = rmfield(wvfParams, 'conepsf');
wvfParams = rmfield(wvfParams, 'coneSceFrac');
wvfParams = rmfield(wvfParams, 'coneWeights');
wvfParams = rmfield(wvfParams, 'T_cones');
wvfParams = rmfield(wvfParams, 'weightingSpectrum');
