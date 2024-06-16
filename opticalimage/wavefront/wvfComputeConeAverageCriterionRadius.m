function [coneAvgCriterionRadius, coneCriterionRadii, wvfPOut] = ...
    wvfComputeConeAverageCriterionRadius(...
    wvfP, defocusDiopters, criterionFraction)
% Calculate the cone averaged criterion radius of the PSF
%
% Syntax:
%   [coneAvgCriterionRadius, wvfPOut] = ...
%       wvfComputeConeAverageCriterionRadius( ...
%       wvfP, defocusDiopters, criterionFraction)
%
% Description:
%    Calculate the cone averaged criterion radius of the PSF. This is the
%    radius that contains the criterion fraction of the PSF mass.
%
%    This calculation depends on a number of values specified in the
%    wavefront structure.
%       wvfGet(wvfP, 'criterionFraction')
%       wvfGet(wvfP, 'conePsfInfo');
%
%    Examples are provided in the code.
%
% Inputs:
%    wvfP                 - Input wavefront struct
%    defocusDiopters      - Defocus zernike coefficient, in diopters
%    criterionFraction    - What fraction of PSF mass contained within
%                           criterion radius?
%
% Outputs:
%    coneAvgCriterionRadius   - Cone averaged criterion radius
%    coneCriterionRadii       - Criterion radii for each cone class.
%    wvfPOut                  - Wavefront struct with passed defocus and
%                               psf computed. Defocus is set (not added
%                               in), using wvfSet(wvfP, 'calc observer
%                               accommodation'), and is thus not directly
%                               in the Zernike coefficients.
%
% Optional key/value pairs
%     None.
%
% ieExamplesOne('wvfComputeConeAverageCriterionRadius')
%
% See also:
%     wfvGet, conePsfInfoGet, wvfComputeOptimizedConePsf

% History:
%    01/15/18  dhb  Started to bring this into the modern era
%    01/18/18  jnm  Formatting

% Examples:
%{
% ETTBSkip
%
% Requires ISETBio.  Might also be out of date.
% Compute cone weighted PSFs using default parameters for conePsfInfo.
wvf = wvfCreate('wave', 400:10:700);

% Compute with no defocus.  Note that wvfCompute is called
% inside of wvfComputeConeAverageCriterionRadius, so we don't
% need to call it in advance.  But since wvf isn't returned,
% you would have to call it if you wanted to use wvf at this
% level of the code.
defocusDiopters = 0;
criterionFraction = 0.5;
[coneAvgCriterionRadius, coneCriterionRadii] = ...
    wvfComputeConeAverageCriterionRadius(wvf, ...
    defocusDiopters, criterionFraction)

% And with one diopter
defocusDiopters = 1;
criterionFraction = 0.5;
[coneAvgCriterionRadius, coneCriterionRadii] = ...
    wvfComputeConeAverageCriterionRadius(wvf, ...
    defocusDiopters, criterionFraction)
%}

% Set defocus
pupilDiameterMM = wvfGet(wvfP, 'measured pupil size');
defocusMicrons = wvfDefocusDioptersToMicrons(defocusDiopters, ...
    pupilDiameterMM);
wvfPOut = wvfSet(wvfP, 'zcoeffs', defocusMicrons, 'defocus');
wvfPOut = wvfCompute(wvfPOut);

% Get the cone weighted PSFs
conePSF = wvfGet(wvfPOut, 'cone psf');
nCones = size(conePSF, 3);

% Get the criterion radius for each cone and average these up, weighting
% the cone classes as specified. The cone weights sum to 1, so what we get
% is in fact the weighted average.
coneWeighting = conePsfInfoGet(wvfGet(wvfPOut, 'calc cone psf info'), ...
    'coneWeighting');
coneCriterionRadii = zeros(nCones, 1);
coneAvgCriterionRadius = 0;
for j = 1:nCones
    coneCriterionRadii(j) = ...
        psfFindCriterionRadius(conePSF(:, :, j), criterionFraction);

    coneAvgCriterionRadius = ...
        coneAvgCriterionRadius + coneWeighting(j)*coneCriterionRadii(j);
end

end
