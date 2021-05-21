function scene = scenePointArray(scene,sz,pointSpacing,spectralType)
% Make a point array stimulus for evaluating the optics
%
%     scene = scenePointArray(scene,[sz=128],[pointSpacing=16],[spectralType='d65'])
%
% The point array scene clarifies the PSF at a variety of locations in the optical
% image.  It also gives a sense of the geometrical distortions.
%
% SZ defines the row and column size of the image.           (default: 128)
% pointSpacing defines the distance between points in pixels (default: 16)
% The spectrum is D65 by default.
%   Alternative spectral types are 'ee' (equal energy) and 'ep' (equal photons)
%
%Example:
%   scene = sceneCreate;
%   scene = scenePointArray(scene);
%   scene = scenePointArray(scene,64,8,'d65');
%   scene = scenePointArray(scene,64,8,'ee');
%   scene = scenePointArray(scene,64,8,'ep');
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('scene'), error('Scene structure required'); end
if ieNotDefined('sz'), sz = 128; end
if ieNotDefined('pointSpacing'), pointSpacing = 16; end
if ieNotDefined('spectralType'), spectralType = 'd65'; end

scene = sceneSet(scene, 'name', 'pointarray');

scene = initDefaultSpectrum(scene,'multispectral');
wave  = sceneGet(scene,'wave');
nWave = sceneGet(scene,'nwave');

d = zeros(sz); idx = round(pointSpacing/2):pointSpacing:sz;
d(idx, idx) = 1;

switch lower(spectralType)
    case {'d65'}
        illPhotons = Energy2Quanta(wave,ieReadSpectra('D65',wave));
    case {'ee','equalenergy'}
        illPhotons = Energy2Quanta(wave,ones(nWave,1));
    case {'ep','equalphoton'}
        illPhotons = ones(nWave,1);
    otherwise
        error('Unknown spectral type:%s\n',spectralType);
end

data = bsxfun(@times, d, reshape(illPhotons, [1 1 nWave]));

scene = sceneSet(scene,'illuminantPhotons',illPhotons);

% Allocate space for the (compressed) photons
scene = sceneSet(scene,'photons',data);
scene = sceneSet(scene,'fov',40);

end