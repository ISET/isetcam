function [scene, dPlane] = sceneDepthRange(scene, depthEdges)
% Create a scene with photons restricted to a particular depth range
%
%  [scene, dPlane] = sceneDepthRange(scene,depthRange)
%
%
% dPlane:  A mask indicating the locations at this depth plane
%          dPlane = sceneGet(scene,'depth plane',depthEdges);
%
% Example:
%   Load piano shelf
%   depthEdges = [0.3625, 0.5289];
%
% Copyright ImagEval Consultants, LLC, 2011.

if ieNotDefined('scene'), error('Scene required'); end
if ieNotDefined('depthEdges'), error('Depth edges required'); end

% Should be in meters from the lens - to double check with Maya ...
dMap = sceneGet(scene, 'depth map');
% imagesc(dMap)

% Find the pixels in the current depth range (logical)?
dPlane = (depthEdges(1) <= dMap) & (dMap < depthEdges(2));
% imagesc(dPlane)

% Mask out the photons that are outside of the depth edges.  The returned
% scene has 0 photons outside of the range.
nWave = sceneGet(scene, 'nWave');
photons = sceneGet(scene, 'photons');

for ii = 1:nWave
    p = photons(:, :, ii);

    % This should probably be 0, not the mean.  I think it is OK for the
    % edge pixels to have a lower intensity at this point.  When the pixel
    % in front is processed, it will add light here to make up the
    % difference.
    p(~dPlane) = 0; % Alternative:
    %p(~dPlane) = mean(p(:));   % Alternative:
    photons(:, :, ii) = p; %
end
% figure; imageSPD(photons,sceneGet(scene,'wave'));

% Put in the photons
scene   = sceneSet(scene,'photons',photons);

% Adjust the depth map; in this case, it is more or less an index to those
% parts of the scene that were saved.  The ones that were out of the depth
% range are set to 0.
dMap = sceneGet(scene, 'depth map');
scene = sceneSet(scene, 'depth map', dMap.*dPlane);

return;
