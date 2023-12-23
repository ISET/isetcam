function scene = sceneRamp(scene, sz)
% Intensity ramp (see L-star chart for L* steps)
%
% Syntax:
%   scene = sceneRamp(scene, [sz])
%
% Description:
%    Intensity ramp (see L-star chart for the L* steps). Set the scene's
%    name to 'ramp', the spectrum to 'hyperspectral', the illuminant to
%    'equal photons' with a lumosity of 100.
%
% Inputs:
%    scene - A scene structure
%    sz    - (Optional) The ramp size. Default 128.
%
% Outputs:
%    scene - The modified scene structure
%
% Optional key/value pairs:
%    None.
%

if notDefined('scene'), error('Error: scene must be provided.'); end
if notDefined('sz'), sz = 128; end

scene = sceneSet(scene, 'name', 'ramp');
scene = initDefaultSpectrum(scene, 'hyperspectral');
nWave = sceneGet(scene, 'nwave');
wave = sceneGet(scene, 'wave');

img = imgRamp(sz);
img = img / (max(img(:)));

il = illuminantCreate('equal photons', wave, 100);
scene = sceneSet(scene, 'illuminant', il);

img = repmat(img, [1, 1, nWave]);
[img, r, c] = RGB2XWFormat(img);
illP = illuminantGet(il, 'photons');
img = img * diag(illP);
img = XW2RGBFormat(img, r, c);
scene = sceneSet(scene, 'photons', img);

end