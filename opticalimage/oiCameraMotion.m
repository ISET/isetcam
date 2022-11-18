function oiShifted = oiCameraMotion(oi, options)
% Use a depthmap to drive disparity
% for simulating camera motion
%
% D. Cardinal, Stanford University, 2022

% Arguments:
%  oi -- An oi (Optical Image) struct with a depthmap
% Options:
%  amount -- A cell array of X,Y camera motion pairs (m) for each frame
%            after the first one (which is assumed to be 0,0)
%  focalLength -- distance from lens to sensor in meters

% Note: the motion array needs to match the number of frames - 1
%       for now. Can probably automate

% Note: For now motion is per frame, as we don't have the exposure time
%       when we create the burst OI (since we re-use it)

% TODO: Currently we "fill" with black. That should be flexible,
%       and ideally we should support some fancy infill routines

%{
Test code:

sensor = sensorCreate('imx363');
load('oi_001.mat', 'oi'); % get an OI
aeMethod = 'specular';
aeLevels = .8;
aeTime = autoExposure(oi,sensor, aeLevels, aeMethod);
burstFrames = 3;
burstTimes = repelem(aeTime/burstFrames, burstFrames);

sensor_burst = sensorSet(sensor,'exp time',burstTimes);
sensor_burst = sensorSet(sensor_burst, 'exposure method', 'burst');
sensor_burst = sensorCompute(sensor_burst,oiBurst);
%}
arguments
    oi = oiCreate();
    options.amount = {[0 .1], [0 .2]};
    options.focalLength = .004; % meters -- smartphone esque
end

% We have:
data  =  oi.data.photons;
illuminance = oi.data.illuminance;
depth =  oi.depthMap;

% We'll fix these for now, but should be computed
cameraShift = options.amount; % horizontal & vertical in meters
focalLength = options.focalLength; % meters 

%{
In principle, the idea is to shift each pixel in the image by an
amount inversely-proportional to its depth.

I think the math is something like:

camera shift (m)     image shift (m) 
----------------  =  ----------------
object distance (m)  focal length (m)

image shift * odist = fl * camera shift
image shift = (fl * camera shift) / odist
%}

% Start with our simple OI input:
oiShifted = oi;

% So we can build a "shift array" based on depth
for aShift = 1:numel(cameraShift)
    useShift = cameraShift{aShift};
    shiftMap = zeros(size(depth,1), size(depth,2), 2);
    shiftMap(:,:,1) = (useShift(1) .* focalLength) ./ depth;
    shiftMap(:,:,2) = (useShift(2) .* focalLength) ./ depth;
    % get rid of nonsense results
    shiftMap(isinf(shiftMap)|isnan(shiftMap)) = 0; % Replace NaNs and infinite values with zeros
    % It is in meters, so we need to correct for pixels
    % We don't know our sensor yet, so need a placeholder
    shiftMap = shiftMap * 100000;

    % use our initial data as the baseline for our shift image
    shiftData = data;
    shiftIlluminance = illuminance;

    % see what happens if we don't start with fill
    shiftData(:,:,:) = 0;
    shiftIlluminance(:,:,:) = 0;


    for ii = 1:size(data,1) % rows
        for iii = 1:size(data,2) % columns

            newLocation = [shiftMap(ii,iii,1) shiftMap(ii,iii,2)] + [ii iii];
            newLocation = floor(newLocation) + 1; % should grid fit!
            % only fill in slots we have
            if newLocation(1) <= size(data,1) && newLocation(2) <= size(data,2) ...
                    && newLocation(1) >= 1 && newLocation(2) >= 1
                shiftData(newLocation(1),newLocation(2),:) = data(ii,iii,:);
                if ~isempty(illuminance)
                    shiftIlluminance(newLocation(1),newLocation(2),:) = illuminance(ii,iii,:);
                end
            end
        end
    end
    % Update our return OI with our new data
    % Copying here for debugging, can remove to save memory
    oiShifted.data.photons(:,:,:,end+1) = shiftData;
    oiShifted.data.illuminance(:,:,end+1) = shiftIlluminance;

end



%{
oiWindow(oi);
oiWindow(oiShifted);
%}
%{
That leaves us with voids, that are newly-exposed areas of the scene
Assuming there is no clever pre-rendering of those, we are left
with filling them as best as we can
%}


