function scene = sceneIlluminantSS(scene)
% Convert a ascene illuminant to spatial spectral format
%
%    scene = sceneIlluminantSS(scene)
%
% We use the spatial spectral format to modulate the illumination intensity
% or spectrum across an image.  Many scenes are initialized with a pure
% spectral format (1-d vector).  This routine replicates the single
% spectrum into the spatial spectral format so that we can then process the
% illuminant across space.
%
% Example:
%    scene = sceneCreate;  sceneGet(scene,'illuminant format')
%    scene = sceneIlluminantSS(scene);
%    sceneGet(scene,'illuminant format')
%    ieAddObject(scene); sceneWindow;
%
% Copyright Imageval LLC, 2015

if ieNotDefined('scene'); error('scene required'); end
iFormat =  sceneGet(scene,'illuminant format');

switch iFormat
    case 'spectral'
        iPhotons = sceneGet(scene,'illuminant photons');
        sz = sceneGet(scene,'size');
        nWave = sceneGet(scene,'n wave');
        foo = repmat(iPhotons(:),[1,sz(1),sz(2)]);
        iPhotons = permute(foo,[ 2 3 1]);
        scene = sceneSet(scene,'illuminant photons',iPhotons);

    case 'spatial spectral'
        % Already in spatial spectral format
        return;
    otherwise
        error('Unknown illuminant format');
end


end
