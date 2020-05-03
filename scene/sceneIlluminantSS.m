function scene = sceneIlluminantSS(scene,pattern)
% Convert a scene illuminant to spatial spectral format
%
% Synopsis:
%    scene = sceneIlluminantSS(scene)
%
% Inputs:
%   scene:    An isetcam scene
%   pattern:  A spatial pattern to apply to the illuminant and radiance
%            (optional)
%
% Return
%   scene:   Modified scene with the illuminant (and radiance) made
%            spatial-spectral and scaled by pattern
%
% Description:
%  Many scenes are initialized with a pure
%  spectral format (1-d vector).  To introduce a spatial modulation of the
%  illuminant, we convert the scene to this spatial spectral format.  Then
%  we can multiply the illuminant (and radiance) by a scale factor at each
%  location.
%  
%  Without a pattern this routine replicates the single spectrum into the
%  spatial spectral format so that we can then process the illuminant
%  across space.
%
% Examples:  ieExamplesPrint('sceneIlluminantSS');
%
% Copyright Imageval LLC, 2015
%
% See also
%    sceneCreate, sceneIlluminantPattern, s_sceneIlluminantSpace,
%    s_sceneChangeIlluminant, s_sceneIlluminantMixtures
%

% Examples:
%{
 scene = sceneCreate;  
 sceneGet(scene,'illuminant format')
 scene = sceneIlluminantSS(scene);
 sceneGet(scene,'illuminant format')
 sceneWindow(scene);
%}
%{
  scene = sceneCreate;
  sz = sceneGet(scene,'size');
  [X,Y] = meshgrid(1:sz(2),1:sz(1));
  scene = sceneIlluminantSS(scene,X);
  sceneWindow(scene);
%}
%% Make sure we convert to spatial spectral

if ieNotDefined('scene'), error('scene required'); end
if ieNotDefined('pattern'), pattern = []; end

iFormat =  sceneGet(scene,'illuminant format');

switch iFormat
    case 'spectral'
        iPhotons = sceneGet(scene,'illuminant photons');
        sz = sceneGet(scene,'size');
        % nWave = sceneGet(scene,'n wave');
        foo = repmat(iPhotons(:),[1,sz(1),sz(2)]);
        iPhotons = permute(foo,[ 2 3 1]);
        scene = sceneSet(scene,'illuminant photons',iPhotons);

    case 'spatial spectral'
        % Already in spatial spectral format
        
    otherwise
        error('Unknown illuminant format');
end

%% Apply the spatial pattern to the illuminant

if isempty(pattern), return; 
else
    % The user sent in a matrix that defines the illuminant spatial pattern.
    % We apply that pattern to both the illuminant and the scene spectral
    % radiance.  This preserves the local reflectance.
    %
    scene = sceneIlluminantPattern(scene,pattern);
end

end
