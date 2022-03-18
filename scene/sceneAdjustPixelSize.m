function [scene, newD] = sceneAdjustPixelSize(scene, oi, pixelSize)
% Set the scene FOV so the OI samples match a sensor pixel size.
%
% Synopsis
%   [scene, newD]  = sceneAdjustPixelSize(scene, oi, pixelSize)
%
% Brief description
%   For ML applications we often want each point sampled in the scene
%   to correspond to a single pixel in the sensor.  This is one of the
%   routines we use to match the spatial sampling between the scene
%   and the sensor.
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
%  oiCreate('pinhole'), oiCrop

% Examples:
%{

%}
%% Parse input
p = inputParser;
p.addRequired('scene', @(x)isequal(x.type, 'scene'));
p.addRequired('oi', @(x)isequal(x.type, 'opticalimage'));
p.addRequired('pixelSize', @isvector);

p.parse(scene, oi, pixelSize);

%%  Adjust scene to certain distance
%
% The idea is to set the distance from of the scene so that the scene
% sample spacing is equal to the pixel size.
%
% Then we will set the pinhole image plane (controlled by the
% focalLength of the optics) equal to the scene distance.

% With this distance, the scene sample spacing matches the pixel size.
d = sceneGet(scene,'distance');
s = sceneGet(scene, 'sample spacing');
newD = d* (pixelSize / s(1));

scene = sceneSet(scene,'distance',newD);

% oi = oiSet(oi,'optics focal length', newD);

% scene = sceneSet(scene, 'distance', 2 * oi.optics.focalLength);
% ieAddObject(scene);

% Get focal length
% focalLength = oiGet(oi, 'optics focal length', 'm'); % In meters

% These are the number of scene sample pixels
% sceneSize = sceneGet(scene, 'size');
% nPixel = sceneSize(2);

% Width of the sensor in meters that would match the number of scene pixels
% sensorWidth = pixelSize * nPixel;

% Calculate scene hFOV
% sceneFOV = 2 * atand(sensorWidth/(2*newD) ); % Scene hFOV

% With this field of view, we guarantee a precise match
% scene = sceneSet(scene, 'fov', sceneFOV);

end