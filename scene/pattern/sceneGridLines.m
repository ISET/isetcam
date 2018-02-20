function scene = sceneGridLines(scene,sz,lineSpacing,spectralType)
%Create scene comprising an array of grid lines
%
%   scene = sceneGridLines(scene,[sz=128],[lineSpacing=16],[spectralType='d65'])
%
% The grid line scene is useful for visualizing the geometric distortion of
% a lens. The spectral power distribution of the lines is set to D65 unless
% spectralType is set to 'ee' (equal energy) or 'ep' (equal photons).
%
% The sz parameter is the scene size and lineSpacing defines the number of
% samples between the lines.
%
% Examples:
%  scene = sceneCreate;
%  scene = sceneGridLines(scene);
%  scene = sceneGridLines(scene,128,16,'ee');
%  scene = sceneGridLines(scene,128,16,'ep');
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('scene'), error('Scene structure required'); end
if ieNotDefined('sz'), sz = 128; end
if ieNotDefined('lineSpacing'), lineSpacing = 16; end
if ieNotDefined('spectralType'), spectralType = 'ep'; end

scene = sceneSet(scene,'name','gridlines');

scene = initDefaultSpectrum(scene,'hyperspectral');
wave = sceneGet(scene,'wave');
nWave = sceneGet(scene,'nwave');

d = zeros(sz);
d(round(lineSpacing/2):lineSpacing:sz, :) = 1;
d(:, round(lineSpacing/2):lineSpacing:sz) = 1;

% To reduce rounding error problems for large dynamic range, we set the
% lowest value to something slightly more than zero.  This is due to the
% ieCompressData scheme.
d(d==0) = 1e-4;

switch lower(spectralType)
    case {'d65'}
        spd = ieReadSpectra('D65',wave);
        illPhotons = Energy2Quanta(wave,spd);
        % spect = Energy2Quanta(wave,illPhotons);
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