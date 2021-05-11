%% The spatial-spectral illumination representation
%
% ISET scenes represent the scene spectral radiance and the scene
% illuminant.  The spectral radiance is a hypercube of data, that
% is a spectral power distribution at each scene point.
%
% The scene illuminant can be a single spectral power
% distribution, in which case the illuminant is assumed to be the
% same (constant) across the entire scene.
%
% Alternatively, the scene illuminant can also be a hypercube of
% the same size as the scene spectral radiance.  In that case,
% the illuminant, which we call spatial-spectral, is allowed to
% vary across the scene.
%
% See also:  s_sceneIlluminant, s_sceneIlluminantMixtures,
%       sceneIlluminantSS, sceneAdjustIlluminant,
%       sceneAdjustReflectance
%
% (c) Imageval Consulting, LLC 2012

%%
ieInit

%% Create a test scene
scene = sceneCreate('frequency orientation');

% Store this for later use in normalizing the image data
illE = sceneGet(scene, 'illuminant energy');

%% Make the scene illuminant spatial spectral

scene = sceneIlluminantSS(scene);

%% Have a look at the scene illuminant - it will look uniform and white

illEnergy = sceneGet(scene, 'illuminant energy');
[illEnergy, r, c] = RGB2XWFormat(illEnergy);
wave = sceneGet(scene, 'wave');

% This is how we show the any SPD (energy) as an image.
XYZ = ieXYZFromEnergy(illEnergy, wave);
srgb = xyz2srgb(XW2RGBFormat(XYZ, r, c));
vcNewGraphWin;
imagesc(srgb); % Looks white, I guess

%% Adjust the SPD along the rows to be blackbbody radiators from 6500 to 3000 K

illPhotons = sceneGet(scene, 'illuminant photons');
[r, ~, ~] = size(illPhotons);
cTemp = linspace(6500, 3000, r);
spd = blackbody(wave, cTemp);

% Apply the blackbody illuminants down the rows, scaling by the relative
% energy in the original
for rr = 1:r
    illPhotons(rr, :, :) = squeeze(illPhotons(rr, :, :)) * diag((spd(:, rr)./illE(:)));
end

% Adjust the scene radiance to preserve the reflectance.
% When we divide to obtain the reflectance it should be the same
reflectance = sceneGet(scene, 'reflectance');
p = reflectance .* illPhotons;
scene = sceneSet(scene, 'photons', p);
scene = sceneSet(scene, 'illuminant photons', illPhotons);

scene = sceneSet(scene, 'Name', 'Temp varies along rows');
ieAddObject(scene);
sceneWindow;

%% Show the illuminant energy as a mesh

illEnergy = sceneGet(scene, 'illuminant energy');

vcNewGraphWin;
mesh(wave, 1:r, squeeze(illEnergy(:, 1, :)))
xlabel('wavelength')
ylabel('pos')
view([-70, 44]);

%% Show the illuminant as an image

% This code is equivalent to
% scenePlot(scene,'illuminant image')

[illEnergy, r, c] = RGB2XWFormat(illEnergy);
wave = sceneGet(scene, 'wave');

XYZ = ieXYZFromEnergy(illEnergy, wave);
XYZ = XW2RGBFormat(XYZ, r, c);
srgb = xyz2srgb(XYZ);
vcNewGraphWin;
imagesc(srgb); % Looks white

%% Make an intensity varying illuminant, starting with spatial spectral

% Initial illuminant photons
illPhotons = sceneGet(scene, 'illuminant photons');
[r, c, w] = size(illPhotons);

% We will scale across the columns
cc = 1:c;
illScale = 1 + 0.5 * sin(2*pi*(cc / c));
% vcNewGraphWin; plot(wave,spd);

% Scale the illuminant intensity along the cols
for cc = 1:c
    illPhotons(:, cc, :) = squeeze(illPhotons(:, cc, :)) * illScale(cc);
end

% Correct the scene photons to preserve the reflectance
% When we divide to obtain the reflectance it should be the same
reflectance = sceneGet(scene, 'reflectance');
p = reflectance .* illPhotons;
scene = sceneSet(scene, 'photons', p);
scene = sceneSet(scene, 'illuminant photons', illPhotons);

% Have a look
scene = sceneSet(scene, 'name', 'Col harmonic');
ieAddObject(scene);
sceneWindow;

%% Now scale across rows

rr = 1:r;
freq = 1;
illScale = 1 + 0.5 * sin(2*pi*freq*(rr / r));

vcNewGraphWin;
plot(illScale); grid on
title('Scale along the rows');

% Scale across the columns
for ii = 1:r
    illPhotons(ii, :, :) = squeeze(illPhotons(ii, :, :)) * illScale(cc);
end

% Correct the energy for this illuminant
reflectance = sceneGet(scene, 'reflectance');
scene = sceneSet(scene, 'illuminant photons', illPhotons);
scene = sceneSet(scene, 'photons', illPhotons.*reflectance);
scene = sceneSet(scene, 'name', 'Row/col harmonic');

ieAddObject(scene);
sceneWindow;

%%  Show the scene illuminant image

scenePlot(scene, 'illuminant image');

%%
