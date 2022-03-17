function scene = sceneAdjustPixelSize(scene, oi, pixelSize)
% Set the scene FOV so the OI samples match the pixel size.
% Pixel is in meters.
%
% Input:
%  scene     -
%  oi        -
%  pixelSize - in meters.
%
% Output:
%  scene     - scene with adjusted FOV
%
% See also:
%
% Examples:
%{

%}
%% Parse input
p = inputParser;
p.addRequired('scene', @(x)isequal(x.type, 'scene'));
p.addRequired('oi', @(x)isequal(x.type, 'opticalimage'));
p.addRequired('pixelSize', @isvector);

p.parse(scene, oi, pixelSize);

%%
% Adjust scene to certain distance
% There is something I don't understand: why the focal length is not the
% same as oiGet(oi, 'optics focal length')? I think we want to use the one
% stored in optics.focalLength.
scene = sceneSet(scene, 'distance', 2 * oi.optics.focalLength);
ieAddObject(scene);

% Get focal length
focalLength = oiGet(oi, 'optics focal length', 'm'); % In meters



% These are the number of scene sample pixels
sceneSize = sceneGet(scene, 'size');
nPixel = sceneSize(2);

% Width of the sensor in meters that would match the number of scene pixels
sensorWidth = pixelSize * nPixel;

% Calculate scene hFOV
sceneFOV = 2 * atand(sensorWidth/(2*focalLength) ); % Scene hFOV

% With this field of view, we guarantee a precise match
scene = sceneSet(scene, 'fov', sceneFOV);
end