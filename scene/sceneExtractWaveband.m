function sceneW = sceneExtractWaveband(scene,waveList)
%sceneExtractWaveband - Extract wave bands from the scene
%
%   sceneW = sceneExtractWaveband(scene,waveList)
%
% The list of evenly-spaced wavelengths, waveList in nm, is extracted from
% the original scene. The output scene contains the photons in the
% wavelength bands. The new scene does not have a calculated luminance, and
% in fact its luminance differs from the original scene.
%
% If the waveList is a single value, the spectral bin width is set to 1.
% Otherwise it is set to the difference in the (evenly spaced!) wavelength
% list.
%
%Example
%   sceneMonochrome = sceneExtractWaveband(scene,500);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('scene'), scene = vcGetObject('scene'); end
if ieNotDefined('waveList'), error('Wave list must be defined'); end

sceneW = scene;
sceneW = sceneSet(sceneW,'photons',sceneGet(scene,'photons',waveList));
sceneW = sceneSet(sceneW,'wave',waveList);

% if length(waveList) == 1,  sceneW = sceneSet(sceneW,'binwidth',1);
% else                       sceneW = sceneSet(sceneW,'binWidth',waveList(2) - waveList(1));
% end

return;