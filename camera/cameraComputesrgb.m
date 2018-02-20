function [srgbResult, srgbIdeal, raw, camera] = ...
    cameraComputesrgb(camera, sceneName, meanLuminance, sz, scenefov, ...
    scaleoutput,plotFlag)

% [srgbResult, srgbIdeal] = 
%     cameraComputesrgb(camera, sceneName, meanLuminance, sz, scenefov, ...
%     scaleoutput,plotFlag)
%
% Calculate sRGB result and ideal images for a camera and scene.
%
% INPUTS:
%  camera:          camera structure
%  sceneName:       string containing the filename of multispectral scene
%                   Alternatively a scene structure can be passed in.  Then
%                   the scene is used for computing after adjusting the
%                   mean luminance and FOV.
%  meanLuminance:   scalar giving scene mean luminance in cd/m^2 
%                   (default 100) 
%  sz:              length 2 vector that gives the rows and columns of the
%                   output image  (default is current sensor size in
%                   camera, which will be cropped by 10 pixels on each
%                   side)
%  scenefov:        scalar giving the field of view for the scene (larger
%                   than the camera fov results in cropping)
%                   (default is same as camera fov)
%  scaleoutput:     scalar that adjusts overall intensity of lRGB images
%                   for result and ideal   (default is 1)
%  plotFlag:        0 means no images are shown, 1 means the srgbResult is
%                   shown and 2 means srgbResult and srgbIdeal are shown.
%                   Default is backwards compatible (2), but I would like
%                   to change to 0 or 1 (BW).
%
% OUTPUTS:
%  srgbResult:      Result from camera.  Mean value of lrgb is set to match
%                   mean value of ideal lrgb image.  Then lrgb is converted
%                   to srgb.
%  srgbIdeal:       Ideal image calculated by directly calculating without 
%                   noise the  XYZ at each pixel.  Then XYZ is converted to
%                   srgb.
%  raw:             RAW sensor values in volts
%
% Generally saturation starts around meanLuminance of 200.  It depends some
% on the scene though.  We should expect some non-negligible saturation for
% mean luminance values over 200.
%
% Field of view controls the size of the images.  A large fied of view
% gives large images.  Be careful not to oversample the underlying scene by
% having the sensor have a higher resolution than the scene itself.
%
% Example:
%         load('basiccamera_Bayer.mat');
%         sceneName = 'StuffedAnimals_tungsten-hdrs';
%         meanLuminance = 100;
%         [srgbResult,srgbIdeal] = cameraComputesrgb(camera,sceneName,meanLuminance);


%% Check inputs
switch nargin
    case 0
        error('Camera needed.')
    case 1
        error('Scene name needed.')
    case 2
        meanLuminance = 100;    %default value
    case 6
    otherwise
        scaleoutput = 1;  %default value
end


%% Setup scene   (and adjust camera sensor size if desired)
if ischar(sceneName)  % If filename of scene is passed in, load it.
    scene = sceneFromFile(sceneName, 'multispectral');
else  % If scene structure is passed in, use that.
    scene = sceneName;  
end

% Change illuminant to D65
scene = sceneAdjustIlluminant(scene,'D65.mat');

if nargin < 4 || isempty(sz)
    sz = cameraGet(camera,'sensor size');
else
    % If a sensor size is specified, set the camera to that
    camera = cameraSet(camera,'sensor size',sz + 20);
    % Instead of specifying size, it is possible to specify the camera's
    % field of view using:  camera = cameraSet(camera,'sensor fov',fov);
    % 20 is added because 10 pixels on each side will be cropped below
end
    
% Set scene FOV
if nargin<5 || isempty(scenefov)
% Default is that scene's fov is set to match camera's
    oi     = cameraGet(camera,'oi');
    sensor = cameraGet(camera,'sensor');
    sDist  = sceneGet(scene,'distance');
    scenefov = sensorGet(sensor,'fov',sDist,oi);
end
scene = sceneSet(scene,'fov',scenefov);


% Adjust mean luminance
scene = sceneAdjustLuminance(scene,meanLuminance);

if ~exist('plotFlag','var') || isempty(plotFlag), plotFlag = 2; end

%% Calculate ideal XYZ image
[camera,xyzIdeal] = cameraCompute(camera,scene,'idealxyz');
xyzIdeal  = xyzIdeal / max(xyzIdeal(:)) * scaleoutput;
[srgbIdeal, lrgbIdeal] = xyz2srgb(xyzIdeal);

%% Calculate camera result
[camera, lrgbResult] = cameraCompute(camera,'oi',lrgbIdeal);   % OI is already calculated
srgbResult = lrgb2srgb(ieClip(lrgbResult,0,1));

%% Crop border of image to remove any errors around the edge 
%  (this is similar to L3imcrop but with a fixed width)

srgbResult = srgbResult(11:(end-10), 11:(end-10), :);
srgbIdeal  = srgbIdeal(11:(end-10), 11:(end-10), :);

%% Show images - 0 means no image, 1 means srgbResult, 2 means Result and Ideal
if plotFlag > 0
    vcNewGraphWin;
    imagesc(srgbResult)
    axis image, axis off, title(sprintf('%s',cameraGet(camera,'name')));
end

if plotFlag > 1
    vcNewGraphWin;
    imagesc(srgbIdeal)
    axis image, axis off, title('Ideal')
end

%% RAW
if nargout>=3
    raw = cameraGet(camera,'sensor volts');
    raw = raw(11:(end-10), 11:(end-10), :);
end

%% END