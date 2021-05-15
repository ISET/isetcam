function [camera,images] = cameraComputeSequence(camera, varargin)
% Compute an image of one or more scenes shot as a sequence
% using a camera model. For example bracketing or burst photography
%
% The first half is mostly a wrapper on various bits of existing code
% but once we get back an array of images there is an opportunity for
% various approaches to combine them -- ranging from simple summation
% to alignment, tone-mapping, fancy AI stuff, and so on.
%
% I think that will either mean broadening what the IP can do, or 
% adding another ISP-type element.
%
% Input:
%   camera struct, required
%
% Parameter Key/Value pairs:
%   'scenes' -- one or more scenes
%   'exposuretimes' -- one or more exposuretimes
%   'nframes' -- number of frames if different from size of scenes or
%   exposure times
%
%   History:
%       Initial coding: DJC, December, 2020
% 
% check for required camera structure
if ~exist('camera', 'var') || isempty(camera), error('camera struct required'); end

%% Decode key/val args

p = inputParser;
varargin = ieParamFormat(varargin);

p.addParameter('scenes',cameraGet('scene'));
p.addParameter('exposuretimes', 1); % probably should do an Auto-Exposure thing?
p.addParameter('nframes', 1);

p.parse(varargin{:});

scenes = p.Results.scenes;
exposuretimes = p.Results.exposuretimes;
nframes = p.Results.nframes;

% this is pretty messed up. Something better would be:
% scene = 1 exposure = 1, standard image
% scene = 1 exposure = n, burst photography or hdr with motionless scene
% scene = n exposure = 1, alternate type of burst photography
% scene = n exposure = n, burst or hdr photography with changing scene
% scene = n exposure = m, need to calculate what to do

if (numels(scenes) > 1 || numels(eposuretimes) > 1) && numels(scenes) ~= numels(exposuretimes)
    error("For multiple scenes and frames, for now they need to be the same");
else
    warning("Need to add the ability to a variety of cases like multiple exposures of 1 scene and vice versa");
end

% assume we have rationalized the number of scenes and exposures
% to be the same
images = [];
for index = 1:numels(scenes) % iterate through one or more scenes
    scene = scenes(index);
    eTime = exposuretimes(index);
    
    % we need to set the exposure time for the camera's current sensor
    sensor = cameraGet(camera, 'sensor');
    sensor = sensorSet(sensor, 'exposure time', eTime);
    camera = cameraSet(camera, 'sensor', sensor);
    
    % cameraCompute runs all the way through the pipeline
    % what if we want to do something 'smarter' about combining them?
    % the current ip structure doesn't support multiple incoming images
    [camera, renderedImage] = cameraCompute(camera, scene);
    images(end+1) = renderedImage; %#ok<AGROW>
end


