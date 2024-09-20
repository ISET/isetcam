function scene = scenePointArray(scene,sz,pointSpacing,spectralType,pointSize)
% Make a point array stimulus for evaluating the optics
%
% Synopsis
%  scene = scenePointArray(scene,[sz=128],[pointSpacing=16],[spectralType='d65'],[pointSize = 1])
%
% Description
%
%  A scene with a point array scene clarifies the PSF at a variety of
%  locations in the optical image.  It also gives a sense of the
%  geometrical distortions.  
%
% Inputs
%   scene - an initialized scene structure
%   sz    - row and column size of the image (default: 128)
%   pointSpacing - distance between points in pixels (default: 16)
%   spectrum -  {'equal energy','equal photon','d65'}   D65 by default
%   pointSize - 1 by default.  Can be an integer > 1
%
% Return
%   scene
%
%Example:
%   scene = sceneCreate;
%   scene = scenePointArray(scene);
%   scene = scenePointArray(scene,64,8,'d65');
%   scene = scenePointArray(scene,64,8,'ee');
%   scene = scenePointArray(scene,64,8,'ep');
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also
%   sceneCreate

if ieNotDefined('scene'), error('Scene structure required'); end
if ieNotDefined('sz'), sz = [128 128]; end
if ieNotDefined('pointSpacing'), pointSpacing = 16; end
if ieNotDefined('spectralType'), spectralType = 'd65'; end
if ieNotDefined('pointSize'),    pointSize = 1; end

scene = sceneSet(scene, 'name', 'pointarray');

scene = initDefaultSpectrum(scene,'multispectral');
wave  = sceneGet(scene,'wave');
nWave = sceneGet(scene,'nwave');

% From here on out, sz is row,col
if isscalar(sz), sz = [sz,sz]; end

% Make an image of the points with size 1
d = zeros(sz); 
idx = round(pointSpacing/2):pointSpacing:sz(2);
idy = round(pointSpacing/2:pointSpacing:sz(1));
d(idy, idx) = 1;

% Make the points bigger by convolution with a box equal to point size
if pointSize > 1
    pointSize = round(pointSize);
    kernel = ones(pointSize,pointSize);
    d = conv2(d,kernel,'same');
end

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