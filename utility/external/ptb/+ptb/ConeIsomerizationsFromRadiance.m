function [isoPerCone, pupilDiamMm, photoreceptors, irradianceWattsPerM2] = ...
    ptbConeIsomerizationsFromRadiance(radiance, wave, pupilDiamMm, ...
    focalLengthMm, integrationTimeSec, mPigmentAdjustment)
% [isoPerCone,pupilDiamMm,photoreceptors,irradianceWattsPerM2] = ...
%   ptbConeIsomerizationsFromSpectralRadiance(radiance,wave,pupilDiamMm,...
%    focalLengthMm,integrationTimeSec,[mPigmentAdjustment])
%
% Compute LMS human cone isomerizations from scene spectral radiance in
% Watts/[m2-sr-nm].
%
% radiance:            The scene radiance (watts/sr/m2/nm)
% wave:                The wavelength samples (nm)
% pupilDiamMm:         Pupil diameter in millimeters
% focalLengthMm:       Focal length in millimeters
% integrationTimeSec:
% mPigmentAdjustment:  Macular pigment density adjustment. 0 means
%                      standard amount (which is XXX).
%
%Returns:
% isoPerCone:            Isomerizations per cone
% pupilDiamMm:
% photoreceptors:        Structure with information about sensors
% irradianceWattsPerM2:  Irradiance derived from
%
% This routine is set up for a quick commparison to isetbio calculations.
% The underlying code is demonstrated and (sort of) documented in PTB
% routine IsomerizationsInEyeDemo.
%
% The other key thing is that after the call to FillInPhotoreceptors, the
% field isomerizationAbsorbtance of the photoreceptors struct contains the
% spectral sensitivities of the LMS cones.  These are in quantal units
% (probability of an isomerization).
%
% If the macularPigmentDensityAdjustment argument is passed, it is added to
% the default.
%
% focalLengthMm = 16.6;
% wave = [400:10:700];
%
% 8/4/13  dhb  Wrote it.
%
% DHB/BW ISETBIO Team, 2013

%% Set up PTB photoreceptors structure

% We'll do the computations at the wavelength spacing passed in for the
% spectrum of interest.
whatCalc = 'CIE2Deg';
photoreceptors = DefaultPhotoreceptors(whatCalc);
photoreceptors.eyeLengthMM.source = num2str(focalLengthMm);
photoreceptors.nomogram.S = WlsToS(wave(:));
S = photoreceptors.nomogram.S;
if (nargin > 5 && ~isempty(mPigmentAdjustment))
    photoreceptors.macularPigmentDensity.adjustDen = mPigmentAdjustment;
end
photoreceptors = FillInPhotoreceptors(photoreceptors);

% Convert units to power per wlband rather than power per nm. Units of
% power per nm is the PTB way, for better or worse.
radianceWattsPerM2Sr = radiance * S(2);

% Find pupil area, needed to get retinal irradiance, if not passed.
%
% In that case, pupil area based on the luminance of stimulus according
% to the algorithm specified in the photoreceptors structure.
load T_xyz1931

T_xyz = SplineCmf(S_xyz1931, 683*T_xyz1931, S);
theXYZ = T_xyz * radianceWattsPerM2Sr;
theLuminance = theXYZ(2);
if (nargin < 3 || isempty(pupilDiamMm))
    [pupilDiamMm, pupilAreaMm2] = PupilDiameterFromLum(theLuminance, photoreceptors.pupilDiameter.source);
else
    pupilAreaMm2 = pi * ((pupilDiamMm / 2)^2);
end

% Convert radiance of source to retinal irradiance
irradianceWattsPerUm2 = RadianceToRetIrradiance(radianceWattsPerM2Sr, S, ...
    pupilAreaMm2, photoreceptors.eyeLengthMM.value);

% Pass back to calling routine in areal units of M2 and
% spectral units of 'per nm'.
irradianceWattsPerM2 = 1e12 * irradianceWattsPerUm2 / S(2);

%% Do the work in toolbox function
[isoPerConeSec, absPerConeSec, photoreceptors] = ...
    RetIrradianceToIsoRecSec(irradianceWattsPerUm2, S, photoreceptors);

isoPerCone = isoPerConeSec * integrationTimeSec;


end