function scene = ...
    sceneSlantedBar(scene, imSize, barSlope, fieldOfView, wave)
% Set the scene to equal photons across the wavelength(s)
%
% Syntax:
%   scene = sceneSlantedBar(scene, imSize, barSlope, fieldOfView, wave)
%
% Description:
%    This function is to set the scene to equal photons across the
%    wavelengths according to the specified parameters.
%
% Inputs:
%    scene       - The scene structure
%    imSize      - (Optional) The image size. Default 384.
%    barSlope    - (Optional) The slope of the bar. Default is 2.6, flowing
%                  from the upper left corner to the lower right.
%    fieldOfView - (Options) The field of view in degrees. Default is 2.
%    wave        - (Optional) The wavelength(s). Default is 400:10:700.
%
% Outputs:
%    scene       - The modified scene structure.
%
% Optional key/value pairs:
%    None.
%

if notDefined('imSize'), imSize = 384; end
if notDefined('barSlope'), barSlope = 2.6; end
if notDefined('fieldOfView'), fieldOfView = 2; end
if notDefined('wave'), wave = 400:10:700; end
scene = sceneSet(scene, 'name', 'slantedBar');
scene = sceneSet(scene, 'wave', wave);
wave = sceneGet(scene, 'wave');
nWave  = sceneGet(scene, 'nwave');

% Make the image
imSize = round(imSize / 2);
[X, Y] = meshgrid(-imSize:imSize, -imSize:imSize);
img = zeros(size(X));

%  y = barSlope * x defines the line. We find all the Y values that are
%  above the line
list = (Y > barSlope * X);

% We assume target is perfectly reflective (white), so the illuminant is
% the equal energy illuminant; that is, the SPD is all due to the
% illuminant
img(list) = 1;

% Prevent dynamic range problem with ieCompressData
img = ieClip(img, 1e-6, 1);

% Now, create the illuminant
il = illuminantCreate('equal energy', wave);
scene = sceneSet(scene, 'illuminant', il);
illP = illuminantGet(il, 'photons');

% Create the scene photons
photons = zeros(size(img, 1), size(img, 2), nWave);
for ii = 1:nWave, photons(:, :, ii) = img * illP(ii); end
scene = sceneSet(scene, 'photons', photons);

% Set the field of view
scene = sceneSet(scene, 'horizontalfieldofview', fieldOfView);

end