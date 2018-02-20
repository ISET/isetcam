function lum = ieLuminanceFromPhotons(photons,wave)
%Calculate luminance (cd/m2) and related quantities (lux,lumens,cd) from spectral
% photons
%
%  lum = ieLuminanceFromPhotons(photons,wave)
%
% Purpose:
%   Converts photons into energy and then calls ieLuminanceFromEnergy.
%
%   See the comments and example in that file.
%
% Copyright ImagEval Consultants, LLC, 2003.

energy = Quanta2Energy(wave,photons);
lum = ieLuminanceFromEnergy(energy,wave);

return;


