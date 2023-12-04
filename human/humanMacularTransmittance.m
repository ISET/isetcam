function oi = humanMacularTransmittance(oi, dens)
% Set the macular pigment as the optical transmittance in an optical image
%
% Syntax:
%   oi = humanMacularTransmittance(oi, [dens])
%
% Description:
%    Set the macular pigment as the optical transmittance in an oi.
%
%    Dens refers to the pigment density. The default is 0.35 for the
%    central fovea. It drops to zero a few degrees eccentric from the fovea
%
% Inputs:
%    oi   - Struct. The optical image structure.
%    dens - (Optional) Numeric. The pigment density. Default 0.35.
%
% Outputs:
%    oi   - Struct. The modified optical image structure.
%
% Optional key/value pairs:
%    None.
%

% History:
%    xx/xx/03       Copyright ImagEval Consultants, LLC, 2003.
%    06/21/18  jnm  Formatting

% This density is assumed in Smith-Pokorny and Stockman, I think
if notDefined('dens'), dens = 0.35; end
if notDefined('oi'), oi = vcGetObject('OI'); end

optics = oiGet(oi, 'optics');
wave   = opticsGet(oi, 'wave');

t = macular(dens, wave);
optics = opticsSet(optics, 'transmittance', t.transmittance);
oi = oiSet(oi, 'optics', optics);

end