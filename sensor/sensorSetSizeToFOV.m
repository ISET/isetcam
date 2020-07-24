function [sensor,actualFOV] = sensorSetSizeToFOV(sensor,newFOV,~,oi)
% Adjust sensor rows and columns so that horizontal FOV is deg (angle)
%
% Synopsis
%   [sensor,actualFOV] = sensorSetSizeToFOV([sensor],newFOV,[scene],[oi])
%
% Brief description
%    Adjust the size of the sensor to achieve a particular horizontal field
%    of view.  The scene and oi data are needed to make this adjustment
%
% Inputs
%   sensor - sensor structure
%   newFOV - Desired horizontal field of view
%   scene  - the scene structure, which includes the distance
%   oi     - the optical image structure which includes focal length info
%
% Optional key/val pairs
%   N/A
%
% Returns
%   sensor - adjusted sensor
%   actualFOV - The adjustment can not be exact because of CFA
%     considerations; the best estimate of the actual adjustment is
%     returned.
%
% Description
%  If newFOV is a scalar, the aspect ratio of the sensor is left
%  approximately unchanged. If newFOV is a 2-vector, the values are treated
%  as (horizontal vertical) FOV and both columns and rows are changed.
%
%  The final sensor size is not always a perfect match because the final
%  size must be a multiple of the cfa size.
%
%  The FOV of the sensor depends on the focal length to the optics and the
%  size of the sensor. Hence, we normally send in the oi.  We should never
%  have to send in the scene and that will be deprecated.
% 
%  We try to handle the human cone array case, which is special, by catching
%  the string 'human' in the name and saying the block size is one.  This is
%  managed in the sensorSet/Get operations.  But human work should really be
%  in ISETBio.
%
%
% Examples:  ieExamplesPrint('sensorSetSizeToFOV');
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also
%   sensorSet, sensorAdjustIlluminant, sensorAdjustLuminance

% Examples:
%{
 scene = sceneCreate; oi = oiCreate; sensor = sensorCreate;
%}
%{
 sensor = sensorSetSizeToFOV(sensor,1,scene,oi);
%}
%{
  sensor = sensorSetSizeToFOV(sensor,30,scene,oi);
%}
%{
  [sensor,fov] = sensorSetSizeToFOV(sensor,[3,1],scene,oi);
%}
%{
  [sensor, fov] = sensorSetSizeToFOV(sensor,[3,3],scene,oi);
%}

%% Parameters

% It appears that we do not really need to send in the scene
if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('newFOV'), error('Must specify desired horizontal field of view (degrees)'); end
% if ieNotDefined('scene'), scene = [];  end
if ieNotDefined('oi'), oi = [];  end

% Get the size.  If size is 0,0 set to a small size.  Not sure when it is
% ever empty, but that is what we had here for a while.
sz = sensorGet(sensor,'size');
if isempty(sz) || isequal(sz,[0 0])
    sz = [32,32];
    sensor = sensorSet(sensor,'size',sz);
end

% Notes on FOV formula for sensor
%  val = ieRad2deg(2*atan(0.5*width/distance));
%  desired width is
%   distance     = opticsGet(oiGet(oi,'optics'),'focallength');
%   desiredWidth = 2*distance*tan(ieDeg2rad(deg)/2);

if length(newFOV) == 1
    
    % This part is dangerous.  It is the part where scene and oi are used.
    % Same in the other part of the if/else
    %
    % To compute the horizontal FOV, we need to know the distance from the
    % sensor to the optics.  Hence, we need to know oi and scene.
    %
    % If scene and oi are empty, then sensorGet uses the currently selected
    % ones. If none are selected, then it uses some arbitrary default
    % values. See the code in sensorGet.
    
    %
    % The desired width should create the new field of view.  The distance
    % to the lens is the focal length.
    flength = oiGet(oi,'optics focal length');
    desiredWidth = 2*flength*tand(newFOV/2);
    currentWidth = sensorGet(sensor,'width');
    newSize = round(sz * (desiredWidth/currentWidth));
    
elseif length(newFOV) == 2
    % User sent in both horizontal and vertical field of view parameters
    hFOV = newFOV(1);
    vFOV = newFOV(2);
    
    % To compute the horizontal FOV, we need to know the distance from the
    % sensor to the optics.  Hence, we need to know oi and scene.
    % If scene and oi are empty, then sensorGet uses the currently selected
    % ones. If none are selected, then it uses some arbitrary default values.
    % See the code in sensorGet.
    flength       = oiGet(oi, 'optics focal length');
    desiredWidth  = 2*flength*tand(hFOV/2);
    desiredHeight = 2*flength*tand(vFOV/2);
    currentWidth  = sensorGet(sensor, 'width');
    currentHeight = sensorGet(sensor, 'height');
    
    newSize = round([sz(1) * (desiredHeight/currentHeight),sz(2) * (desiredWidth/currentWidth)]);
else
    error('newFOV is wrong.');
end

%% Adjust FOV for CFA constraints

% The new sensor has to have at least the number of pixels in the cfa block
% pattern, and it has to be a multiple of the number of pixels in the block
% pattern.  We make it slightly larger than absolutely necessary.

% For the human photoreceptor case.
% This size adjustment can be a problem when the pattern is, say, random
% and the cfaSize is the whole size of the original array.  The size
% adjustment  is only good for block sizes that are small compared to the
% array.  

cfaSize = sensorGet(sensor,'cfaSize');
if cfaSize ~= sz
    newSize = ceil(newSize ./ cfaSize).* cfaSize;
    % If for some reason ceil(sz/cfaSize) is zero, we set size to one pixel
    % cfa.
    if newSize(1) == 0, newSize = cfaSize; end
end

% Set the new sizes.  This call considers the human case.
sensor = sensorSet(sensor,'size',newSize);

% sensor = sensorSet(sensor,'cols',newSize(2));
sensor = sensorClearData(sensor);

%%  The person may want the corrected FOV
if nargout == 2, actualFOV = sensorGet(sensor,'fov'); end

end

