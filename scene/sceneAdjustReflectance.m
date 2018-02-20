function scene = sceneAdjustReflectance(scene,newR)
% Adjust the scene reflectances, keeping the illuminant unchanged
%
% Example:
%
% See also:  sceneAdjustIlluminant, sceneAdjustLuminance
%
% (c) Imageval, 2012

if ieNotDefined('scene'), error('Scene required.'); end
if ieNotDefined('newR'), error('RGB format reflectance required'); end

% Check that the new reflectance size matches the current scene
sz = sceneGet(scene,'size');
[row,col,w] = size(newR);
if sz ~= [row,col], error('Reflectance size mis-match'); end

nWave = sceneGet(scene,'nWave');
if nWave ~=w, error('Wavelength dimension mis-match'); end

%% Format the reflectance for fast multiply

% We multiply the scene illuminant by the reflectance to get the new
% photons
illPhotons = sceneGet(scene,'illuminant photons');

% Format anbd multiply and reformat
[newR,row,col] = RGB2XWFormat(newR);
photons = newR*diag(illPhotons);
photons = XW2RGBFormat(photons,row,col);

% Set
scene = sceneSet(scene,'photons',photons);

end

