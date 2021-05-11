function oi = humanMacularTransmittance(oi, dens)
% Set the macular pigment as the optical transmittance in an optical image
%
%    oi = humanMacularTransmittance(oi,[dens=0.28])
%
%  Dens refers to the pigment density.  The default is 0.28 for the central
%  fovea.  It drops to zero a few degrees eccentric from the fovea
%
% Copyright ImagEval Consultants, LLC, 2003.

% This density is assumed in Smith-Pokorny and Stockman, I think
if ieNotDefined('dens'), dens = 0.35; end
if ieNotDefined('oi'), oi = vcGetObject('OI'); end

optics = oiGet(oi, 'optics');
wave = opticsGet(oi, 'wave');

t = macular(dens, wave);

optics = opticsSet(optics, 'transmittance', t.transmittance);

oi = oiSet(oi, 'optics', optics);

return;
