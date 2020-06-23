function scene = sceneIlluminantPattern(scene,pattern)
% Apply a spatial pattern to the scene illumination
%
% Synopsis
%    scene = sceneIlluminantPattern(scene,pattern)
% Inputs
%   scene:   ISETCam scene
%   pattern: Spatial pattern describing how to modulate the illuminant
%
% Return
%   scene
%
% Examples:  ieExamplesPrint('sceneIlluminantPattern');
%
% See also
%   sceneIlluminantSS

% Examples:
%{
  scene = sceneCreate;
  scene = sceneIlluminantSS(scene);
  sz = sceneGet(scene,'size');
  [X,Y] = meshgrid(1:sz(2),1:sz(1));
  scene = sceneIlluminantPattern(scene,Y);
  sceneWindow(scene);
%}
%{
  scene = sceneCreate;
  scene = sceneIlluminantSS(scene);
  sz = sceneGet(scene,'size');
  [X,Y] = meshgrid(-8:8,-10:10);
  pattern = sqrt(X.^2 + Y.^2) + 1;
  scene = sceneIlluminantPattern(scene,pattern);
  sceneWindow(scene);
%}

%%
if ieNotDefined('scene'),   error('scene required'); end
if ieNotDefined('pattern'), error('pattern required'); end

% The pattern is a matrix that should be the size of the scene.  If the
% user just sent in little shape, we interpolate the pattern to the size of
% the scene
sz = sceneGet(scene,'size');
if size(pattern) ~= sz
    pSize = size(pattern);
    [X,Y] = meshgrid(1:pSize(2),1:pSize(1));
    x = linspace(1,pSize(2),sz(2));
    y = linspace(1,pSize(1),sz(1));
    [U,V] = meshgrid(x,y);
    pattern = interp2(X,Y,pattern,U,V);
end

%% Apply the pattern to both the scene radiance and illuminant radiance

nWave      = sceneGet(scene,'nwave');
photons    = sceneGet(scene,'photons');
illPhotons = sceneGet(scene,'illuminant photons');

for ii=1:nWave
    photons(:,:,ii)    = photons(:,:,ii) .* pattern;
    illPhotons(:,:,ii) = illPhotons(:,:,ii) .* pattern; 
end

scene = sceneSet(scene,'photons',photons);
scene = sceneSet(scene,'illuminant photons',illPhotons);

end
