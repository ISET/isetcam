function oi = oiIlluminantSS(oi,pattern)
% Convert a scene illuminant to spatial spectral format
%
% Synopsis:
%    oi = oiIlluminantSS(oi)
%
% Inputs:
%   scene:    An isetcam optical image
%   pattern:  A spatial pattern to apply to the illuminant and irradiance
%            (optional)
%
% Return
%   oi:   Modified oi with the illuminant (and irradiance) made
%            spatial-spectral and scaled by pattern
%
% Description:
%  Many oi are initialized without an illuminant, and a few with a pure
%  spectral format (1-d vector).  To introduce a spatial modulation of the
%  illuminant, we convert the oi illuminant to this spatial spectral
%  format.  Then we can multiply the illuminant (and irradiance) by a scale
%  factor at each location.
%
%  Without a pattern this routine replicates the single spectrum into the
%  spatial spectral format so that we can then process the illuminant
%  across space.
%
% Examples:  ieExamplesPrint('oiIlluminantSS');
%
% Copyright Imageval LLC, 2020
%
% See also
%    oiCreate, sceneIlluminantPattern, s_sceneIlluminantSpace,
%    s_sceneChangeIlluminant, s_sceneIlluminantMixtures
%

% Examples:
%{
 scene = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);
 thisIll = illuminantCreate; oi = oiSet(oi,'illuminant',thisIll);
 oiGet(oi,'illuminant format')
 oi = oiIlluminantSS(oi);
 oiGet(oi,'illuminant format')
 oiWindow(oi);
%}
%{
 scene = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);
 thisIll = illuminantCreate; oi = oiSet(oi,'illuminant',thisIll);
 sz = oiGet(oi,'size');
 [X,Y] = meshgrid(1:sz(2),1:sz(1));
 oi = oiIlluminantSS(oi,X);
 oiWindow(oi);
%}
%% Make sure we convert to spatial spectral

if ieNotDefined('oi'), error('oi required'); end
if ieNotDefined('pattern'), pattern = []; end

iFormat =  oiGet(oi,'illuminant format');
if isempty(iFormat), error('No oi illuminant present'); end

switch iFormat
    case 'spectral'
        iPhotons = oiGet(oi,'illuminant photons');
        sz = oiGet(oi,'size');
        % nWave = oiGet(scene,'n wave');
        foo = repmat(iPhotons(:),[1,sz(1),sz(2)]);
        iPhotons = permute(foo,[ 2 3 1]);
        oi = oiSet(oi,'illuminant photons',iPhotons);
        
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
    oi = sceneIlluminantPattern(oi,pattern);
end

end
