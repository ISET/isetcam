function [isoPerConeSec,absPerConeSec,photoreceptors] = ...
	RetIrradianceToIsoRecSec(irradianceWatts,irradianceS,photoreceptors)
% [isoPerConeSec,absPerConeSec,photoreceptors] = ...
%		RetIrradianceToIsoRecSec(irradianceWatts,irradianceS,[photoreceptors])
%
% Convert retinal irradiance, measured in watts/um^2-wlinterval to
% isomerizations per cone per second.
%
% The passed photoreceptors structure defines the transmissive media through
% which the light must pass and the properties of the photoreceptors.  It
% is not modified by this routine, but the routine can return default
% values.
%
% Default values return estimates for human L, M, and S foveal cones.
% 
% In many cases, data can either be specified by numerical value or by
% source string.  When both are passed, values override strings.
%
% The routine also returns the absorption rate and a filled in version
% of the photoreceptors structure.
%
% See also: DefaultPhotoreceptors, FillInPhotoreceptors, IsomerizationsInEyeDemo
%   IsomerizationsInDishDemo.
%
% 7/25/03  dhb  Wrote it by pulling in code from elsewhere.

if (nargin < 3 || isempty(photoreceptors))
	photoreceptors = DefaultPhotoreceptors('LivingHumanFovea');
	photoreceptors = FillInPhotoreceptors(photoreceptors);
end

% Define common wavelength sampling for this function.
S = photoreceptors.nomogram.S;

% Put irradiance in quantal units
irradianceQuanta = EnergyToQuanta(S,irradianceWatts);

% Compute rate at which photons are absorbed.
absPerConeSec = PhotonAbsorptionRate(irradianceQuanta,S, ...
	photoreceptors.effectiveAbsorptance,S,photoreceptors.ISdiameter.value);
isoPerConeSec = PhotonAbsorptionRate(irradianceQuanta,S, ...
	photoreceptors.isomerizationAbsorptance,S,photoreceptors.ISdiameter.value);

