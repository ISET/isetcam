function sensor = sensorCrop(sensor,rect)
% Crop a the sensor data, while preserving the CFA
%
% Synopsis
%   sensor = sensorCrop(sensor,rect)
%
% Description
%   The image axis is (1,1) in the upper left.  Increasing y-values run
%   down the image.  Increasing x-values run to the right.
%   The rect parameters are (x,y,width,height).
%   (x,y) is the upper left corner of the rectangular region
%
% Inputs
%   sensor:  ISETCam sensor struct
%   rect:    [x,y,width,height]
%
% Optional variables
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

rect = [25 25 40 40];
test = sensorCrop(sensor,rect);
sensorWindow(test);
%}

%% Parameters
if ieNotDefined('sensor'), error('sensor required'); end

% For now. Though we could allow this to be interactive at some point.
if ieNotDefined('rect'), error('crop rect required'); end

% Modern Matlab returns a Rectangle object, not just a rect vector. We only
% want the Position of the rectangle for this crop.
if isa(rect,'images.roi.Rectangle'), rect = rect.Position; end
%%

% Get the data
cfaSize = sensorGet(sensor,'cfaSize');

% The [x,y, width, height] needs to match the cfaSize.  The cfaSize is
% [row,col].  So we need to deal with that.
cfaSize = fliplr(cfaSize);   

% If the cfa size is even, then the x and y values should be odd The number
% of entries in numel(x:(x + width)) and numel(y:(y + height)) should be a
% multiple of the cfaSize.
%

%% Select rect values that will preserve the CFA pattern

% Here are some test cases
%{
cfaSize = [2,2]; rect = [ 7 9 6 8];  % 7     9     6     8
cfaSize = [2,2]; rect = [ 8 9 6 8]   % 9     9     6     8

cfaSize = [5,3]; rect = [6,10,6,8]   %  6    10    10     9
cfaSize = [5,3]; rect = [ 7 10 5 8]  % 11    10     5     9
cfaSize = [5,3]; rect = [ 8 11 6 9]  % 11    13    10     9

cfaSize = [3,5]; rect = [ 8 11 6 9]  % 10    11     6    10
%}

%
% First deal with x = rect(1), width = rect(3).   
% Then deal with  y = rect(2), height = rect(4)
%
for ii=0:1
    % The x value should start on a multiple of the cfaSize plus 1. 
    thisRem = rem(rect(ii+1),cfaSize(ii+1));
    if thisRem ~= 1
        if thisRem == 0
            rect(ii+1) = rect(ii+1) + 1;
        else
            % Adjust the starting value by the amount we missed by. which gets
            % us to 0 and then add 1.
            rect(ii+1) = rect(ii+1) + (cfaSize(ii+1) - thisRem + 1);
        end
        
    end
    % The total size should be a multiple of the cfaSize
    cnt = numel(rect(ii+1):(rect(ii+1) + rect(ii+3)));
    if rem(cnt,cfaSize(ii + 1))  % Zero if a proper multiple
        % Not an even devisor of the cfaSize.  So add an amount needed to
        % make it a proper multiple
        rect(ii+3) = rect(ii+3) + cfaSize(ii + 1) - rem(cnt,cfaSize(ii+ 1));
    end
end

% These are checks that the adjustment worked.  Though the width and height
% seem to be off a bit.  So we should figure that out and fix it.
assert(rem(rect(1),cfaSize(1)) == 1);
assert(rem(rect(2),cfaSize(2)) == 1);
assert(rem(numel(rect(1):(rect(1) + rect(3))),cfaSize(1)) == 0)
assert(rem(numel(rect(2):(rect(2) + rect(4))),cfaSize(2)) == 0)

%%  Crop the voltage image

% Crop the volts
volts = sensorGet(sensor,'volts');
dv = sensorGet(sensor,'dv');
if isempty(volts)
    % That's weird.  why crop a sensor that has no data?  Just resize.
else
    newVolts = imcrop(volts,rect);
    newSize  = size(newVolts);
    sensor = sensorSet(sensor,'size',newSize);
    sensor = sensorSet(sensor,'volts',newVolts);
end

% Crop the digital values
if ~isempty(dv)
    newDV = imcrop(dv,rect);
    if ~exist('newSize','var')
        newSize = size(newDV);
        sensor = sensorSet(sensor,'size',newSize);
    end
    sensor = sensorSet(sensor,'digital values',newDV);
end

end
