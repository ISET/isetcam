function oiW = oiExtractWaveband(oi, waveList, illuminanceFlag)
%oiExtractWaveband - Extract wave bands from the scene
%
%   oiW = oiExtractWaveband(oi,waveList,illuminanceFlag)
%
% The list of evenly-spaced wavelengths, waveList in nm, is extracted from
% the original optical image (OI). The output OI contains the photons in the
% wavelength bands.
%
% By default, the new OI does not have a calculated illuminance, and
% in fact its illuminance differs from the original OI.  To re-calculate
% the illuminance, set the illuminanceFlag to 1.  Note that the
% sensorCompute function often requires an illuminance if the auto-exposure
% algorithms are used.
%
% If the waveList is a single value, the spectral bin width is set to 1.
% Otherwise it is set to the difference in the (evenly spaced!) wavelength
% list.
%
%Example
%   oiMonochrome =oiExtractWaveband(oi,500);
%   oiMonochrome =oiExtractWaveband(oi,500,1);   %Compute illuminance
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('oi'), scene = vcGetObject('oi'); end
if ieNotDefined('waveList'), error('Wave list must be defined'); end
if ieNotDefined('illuminanceFlag'), illuminanceFlag = 0; end

oiW = oi;
oiW = oiSet(oiW, 'photons', sceneGet(oi, 'photons', waveList));
oiW = oiSet(oiW, 'wave', waveList);

if illuminanceFlag, oiW = oiSet(oiW, 'illuminance', oiCalculateIlluminance(oiW)); end

return;