function sensor = sensorDataRead(sensor,fname,varargin)
% Import sensor data from a file into a sensor struct
%
% Synopsis
%   sensor = sensorDataRead(sensor,fname,varargin)
%
% Inputs
%  sensor
%  fname
%
% Optional key/value pairs
%  croprect    - Crop the input data with a rect
%
% Outputs
%  sensor
%
% Description
%
%
% See also
%

% Examples:
%{
% Create an IMX363 sensor and read a DNG file for the sensor data
 sensor = sensorIMX363('row col',[600 800]);
 fname = which('mcc_direct_sunlight_IMG_20200520_164856.dng');

 % The cropRect start must be a (1:2:end,1:2:end) number
 cropRect = [505 1801 3500 1000];
 sensor = sensorDataRead(sensor,fname,'crop rect',cropRect);
 % sensorWindow(sensor,'scale',true);

 % Visualize whether the RGB alignment is correct
 ip = ipCreate; ip = ipCompute(ip,sensor); ipWindow(ip);
%}

%% 
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('sensor',@isstruct);
p.addRequired('fname',@(x)(exist(x,'file')));
p.addParameter('croprect',[],@isvector);

p.parse(sensor,fname,varargin{:});
cropRect = p.Results.croprect;

%% Let's use the IMG data and put it in a sensor struct to view
[~,~,e] = fileparts(fname);
switch e
    case '.dng'
        [img,~] = dng2raw(fname);
    otherwise
        img = imread(fname);
end


%% Read in and crop the image
% cropI = igCropImage(I,cropArea, buffer, cropCenter)

% imgC = double(igCropImage(img,[200 200]));  % Crops image preserving RGGB Bayer
if ~isempty(cropRect)
    if ~isodd(cropRect(1)) || ~isodd(cropRect(2))
        warning('crop rect not aligned with expected Bayer RGB');
    end
    img = imcrop(img,cropRect);  % Crops image preserving RGGB Bayer
end
img = single(img);

% Set the scale for the votage swing
img = (img/max(img(:)))*0.95*sensorGet(sensor,'pixel voltage swing');

%% Empty the data and set the new data
sensor = sensorClearData(sensor);

sensor = sensorSet(sensor,'volts',img);

end