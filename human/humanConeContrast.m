function coneContrast = humanConeContrast(signalSPD, backgroundSPD, wave, units, mpDensity)
%Calculate  cone contrast of signalSPD superimposed on backgroundSPD
%
%   maxConeContrast = humanConeContrast(signalSPD,backgroundSPD,wave,[units='energy'],[mpDensity=[]])
%
%   The signal and background are in radiance units of energy
%   (watts/sr/m2/nm) or photons (q/sr/m2/nm).  The sample wavelengths are
%   specified in wave (nm). The Stockman cones with a specified macular
%   pigment density mpDensity are used for the calculation.
%
% Example:
%   coneContrast = humanConeContrast(signalSPD,backgroundSPD,[400:1:700],'photons')
%   coneContrast = humanConeContrast(signalSPD,backgroundSPD,[380:4:730],'energy')
%   coneContrast = humanConeContrast(signalSPD,backgroundSPD,[380:4:730],'energy',0)
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('signalSPD'), error('Signal spd must be defined'); end
if ieNotDefined('backgroundSPD'), error('Background spd must be defined.'); end
if ieNotDefined('wave'), error('Wavelength values must be defined.'); end
if ieNotDefined('units'), units = 'energy'; end
if ieNotDefined('mpDensity'), mpDensity = []; end

if length(wave) ~= length(signalSPD), error('Wavelength incorrect.'); end

% Calculation must take place in energy units
if strcmp(units, 'photons') | strcmp(units, 'quanta')
    signalSPD = Quanta2Energy(wave, signalSPD(:)');
    backgroundSPD = Quanta2Energy(wave, backgroundSPD');
end

% The max nominal cone contrast is computed here.  We correct for the
% fact that this is less than 100% later.
cones = humanCones('stockmanAbs', wave, mpDensity);
backCones = cones' * backgroundSPD(:); % The background is always positive
sigCones = cones' * (signalSPD(:)); % The signal can be an increment or decrement
coneContrast = sigCones ./ backCones;

return;