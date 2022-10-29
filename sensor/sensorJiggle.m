function sensor = sensorJiggle(sensor,pixels)
% Simple shift-based motion simulation
%
% Synopsis
%   sensor = sensorJiggle(sensor, pixels)
%
% Description
%   The image axis is (1,1) in the upper left.  Increasing y-values run
%   down the image.  Increasing x-values run to the right.
%   The rect parameters are (x,y,width,height).
%   (x,y) is the upper left corner of the rectangular region
%
% Inputs
%   sensor:  ISETCam sensor struct
%
% Outputs
%
% See also
%   sensorSetSizeToFOV, v_sensorSize
%

% Examples:
%{
scene = sceneCreate;
oi = oiCreate;
oi = oiCompute(oi,scene);
sensor = sensorCreate;
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

test = sensorJiggle(sensor,10);
sensorWindow(test);
%}

%% Parameters
if ieNotDefined('sensor'), error('sensor required'); end

if ieNotDefined('pixels'), error('number of pixels required'); end

% crop does the whole sensor, but we want different crops
% for each capture in a burst
% 
% Not sure how to proceed, so just make our function a no-op for now

end
