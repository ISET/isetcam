function oi = oiIlluminantPattern(oi, pattern)
% Apply a spatial pattern to the scene illumination
%
% Synopsis
%    scene = oiIlluminantPattern(scene,pattern)
% Inputs
%   scene:   ISETCam optical image
%   pattern: Spatial pattern describing how to modulate the illuminant
%
% Return
%   scene
%
% Examples:  ieExamplesPrint('oiIlluminantPattern');
%
% See also
%   oiIlluminantSS, sceneIlluminantSS, sceneIlluminantPattern

% Examples:
%{
scene = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);
thisIll = illuminantCreate; oi = oiSet(oi,'illuminant',thisIll);
oi = oiIlluminantSS(oi);
sz = oiGet(oi,'size');
[X,Y] = meshgrid(1:sz(2),1:sz(1));
oi = oiIlluminantPattern(oi,Y);
oiWindow(oi);
%}

%%
if ieNotDefined('oi'), error('oi required'); end
if ieNotDefined('pattern'), error('pattern required'); end

% The pattern is a matrix that should be the size of the scene.  If the
% user just sent in little shape, we interpolate the pattern to the size of
% the scene
sz = oiGet(oi, 'size');
if size(pattern) ~= sz
    pSize = size(pattern);
    [X, Y] = meshgrid(1:pSize(2), 1:pSize(1));
    x = linspace(1, pSize(2), sz(2));
    y = linspace(1, pSize(1), sz(1));
    [U, V] = meshgrid(x, y);
    pattern = interp2(X, Y, pattern, U, V);
end

%% Apply the pattern to both the scene radiance and illuminant radiance

nWave = oiGet(oi, 'nwave');
photons = oiGet(oi, 'photons');
illPhotons = oiGet(oi, 'illuminant photons');

for ii = 1:nWave
    photons(:, :, ii) = photons(:, :, ii) .* pattern;
    illPhotons(:, :, ii) = illPhotons(:, :, ii) .* pattern;
end

oi = oiSet(oi, 'photons', photons);
oi = oiSet(oi, 'illuminant photons', illPhotons);

end
