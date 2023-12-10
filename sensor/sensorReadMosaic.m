function sensor = sensorReadMosaic(sensor,fname,varargin)
% Import sensor data from a file into a sensor struct
%
% Synopsis
%   sensor = sensorReadMosaic(sensor,fname,varargin)
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
%   Not tested other than with the DNG files from our collaborators.  We
%   should test with different mosaics and we should extend the code to
%   work with something other than GR;GB Bayer format.
%
% Examples
%  ieExamplesPrint('sensorReadMosaic');
%
% See also
%   sensorRead*

% Examples:
%{
 % Create an IMX363 sensor and read a DNG file for the sensor data
 sensor = sensorIMX363('row col',[600 800]);
 fname = which('mcc_direct_sunlight_IMG_20200520_164856.dng');

 % The cropRect start must be a (1:2:end,1:2:end) number
 % cropRect = [505 1801 3500 1000];
 % cropRect = [505 1801 100 100];
 cropRect = [];

 sensor = sensorReadMosaic(sensor,fname,'crop rect',cropRect);
 % sensorWindow(sensor,'scale',true);

 % Visualize whether the RGB alignment is correct
 ip = ipCreate;
 ip = ipSet(ip,'illuminant correction method','gray world');
 ip = ipCompute(ip,sensor); ipWindow(ip);
%}

%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('sensor',@isstruct);
p.addRequired('fname',@(x)(exist(x,'file')));
p.addParameter('croprect',[],@(x)(isempty(x) || isvector(x)));

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

%% Empty the data and set the new data
sensor = sensorClearData(sensor);
sensor = sensorSet(sensor,'size',size(img));
img = single(img);

qm = sensorGet(sensor,'quantization method');
switch qm
    case 'analog'
        % Set the scale for the votage swing
        img = (img/max(img(:)))*0.95*sensorGet(sensor,'pixel voltage swing');
        sensor = sensorSet(sensor,'volts',img);
    case 'linear'
        % voltimg = (img/max(img(:)))*0.95*sensorGet(sensor,'pixel voltage swing');
        % sensor = sensorSet(sensor,'volts',voltimg);
        sensor = sensorSet(sensor,'dv',img);
    otherwise
        error('Unknown quantization method %s\n',qm);
end


end