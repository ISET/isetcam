function [ip,sensor] = ieRadiance2IP(radiance,varargin)
% Convert scene or OI to an IP, carrying along the metadata
%
%   N.B There is an equivalent iset3d function, piRadiance2RGB.  I needed
%   this one for the tutorial t_oiPrinciples.mlx, and it seemed useful.
%
% Syntax
%    [ip,sensor] = ieRadiance2IP(radiance,varargin)
%
% Description
%   After we simulate a scene with ISET3d, and in some other cases, we have
%   the radiance (scene) or irradiance data (oi) as raw data. This function
%   converts the raw data and metadata all the way to the IP level.
%
% Input
%   radiance - Either a scene or oi, usually with some metadata.
%
% Optional key/value pairs
%   sensor        - File name containing the sensor, or a sensor.
%                   Default conforms with the ISETAuto generalization paper
%   pixel size    - Size in microns (e.g. 2)
%   film diagonal - In millimeters, default is 5 mm
%   etime         - exposure time
%
% Output
%   ip  - Computed ip
%   sensor - sensor used for the computation.  Can be reused.
%
% See also
%   piMetadataSetSize, piOI2IP

%%
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('radiance',@isstruct);

p.addParameter('sensor','',@ischar);   % A file name
p.addParameter('pixelsize',[],@isscalar); % um
p.addParameter('filmdiagonal',5,@isscalar); % [mm]
p.addParameter('etime',[],@isscalar); % 
p.addParameter('noiseflag',2,@isscalar);
p.addParameter('conversiongain',[],@isscalar);
p.addParameter('analoggain',1);
p.addParameter('quantization','12 bit',@ischar);  % 12bit, 10bit, 8bit, analog

p.parse(radiance,varargin{:});
radiance     = p.Results.radiance;
sensorName   = p.Results.sensor;
pixelSize    = p.Results.pixelsize;
eTime        = p.Results.etime;
noiseFlag    = p.Results.noiseflag;
analoggain   = p.Results.analoggain;
% converGain   = p.Results.conversiongain;

%% scene to optical image

if isfield(radiance,'type')
    if strcmp(radiance.type,'scene')
        % Convert the scene data to oi data
        oi = piOICreate(radiance.data.photons);
    elseif strcmp(radiance.type,'opticalimage')
        % Typical calculation this way.
        oi = radiance;
    end
else
    error('Input should be a scene or optical image');
end

% Below, we set the pixel size for a 1-1 match to the oi spatial
% sampling resolution.
if isempty(pixelSize)
    pixelSize = oiGet(oi,'width spatial resolution','microns');
end

%% oi to sensor
if isempty(sensorName), sensor = sensorCreate;

    % The default conforms with the ISETAuto generalization paper
    readnoise   = 2e-3;
    darkvoltage = 2e-3;
    [electrons,~] = iePixelWellCapacity(pixelSize);  % Microns
    converGain = 1/electrons;         % voltage swing/electrons
    
    sensor = sensorSet(sensor,'pixel read noise volts',readnoise);
    sensor = sensorSet(sensor,'pixel voltage swing',1);
    sensor = sensorSet(sensor,'pixel dark voltage',darkvoltage);
    sensor = sensorSet(sensor,'pixel conversion gain',converGain);
    sensor = sensorSet(sensor,'quantization method','12bit');

    sensor = sensorSet(sensor,'analog gain', analoggain);
    if ~isempty(pixelSize)
        % Pixel size in meters needed here.
        sensor = sensorSet(sensor,'pixel size same fill factor',pixelSize*1e-6);
    end
elseif ischar(sensorName), load(sensorName,'sensor');
elseif isfield(sensorName,'type') && isequal(sensorName.type,'sensor')
    sensor = sensorName;
end

% Make the sensor pixel size match the oi sample spacing.  The OI is
% computed with a specific size to match some sensor, usually.
sensor = sensorSet(sensor,'match oi',oi);

%% Compute

% This is a special autoExposure method.  It should go into autoExposure
size = oiGet(oi,'size');
zones = getImageZones(size(1), size(2),7,7);
if isempty(eTime)
    for zz = [11,17,19,21,23,25,27,29,39]
        eTime(zz)  = autoExposure(oi,sensor,0.95,'weighted','center rect',round(zones(zz,:)));
    end
    eTime = (mean(eTime));
end
sensor = sensorSet(sensor,'exp time',eTime);

sensor = sensorSet(sensor,'noise flag',noiseFlag); % see sensorSet for more detail

sensor = sensorCompute(sensor,oi);
% fprintf('eT: %f ms \n',eTime*1e3);

% sensorWindow(sensor);

%% Copy metadata

% if isfield(oi,'metadata')
%     if ~isempty(oi.metadata)
%      sensor.metadata          = oi.metadata;
%      sensor.metadata.depthMap = oi.depthMap;
%      sensor                   = piMetadataSetSize(oi,sensor);
%     end
% end

% annotate the sensor?
% sensor = piBatchSceneAnnotation(sensor);

%% Sensor to IP
CFAs = sensor.color.filterNames;
if numel(CFAs)>3
    disp('We only calculate the ip for 3 color channel case.')
    ip = [];
    return
end
ip = ipCreate;

% Choose the likely set of signals the sensor will encounter
ip = ipSet(ip,'conversion method sensor','MCC Optimized');
ip = ipSet(ip,'illuminant correction method','gray world');

% demosaics = [{'Adaptive Laplacian'},{'Bilinear'}];
ip = ipSet(ip,'demosaic method','Adaptive Laplacian'); 
% ip = ipSet(ip, 'demosaic method','analog rccc');
ip = ipCompute(ip,sensor);

% ipWindow(ip);

if isfield(sensor,'metadata')
    ip.metadata = sensor.metadata;
    ip.metadata.eT = eTime;
end

end

%%  Should go into autoExposure

function zones = getImageZones(height, width, numRows, numCols)

% Calculate the size of each zone
zoneHeight = height / numRows;
zoneWidth = width / numCols;

% Initialize the zones array
zones = zeros(numRows * numCols, 4); % Each row: [x, y, width, height]

% Generate the rectangles for each zone
index = 1;
for row = 1:numRows
    for col = 1:numCols
        x = (col-1) * zoneWidth + 1;
        y = (row-1) * zoneHeight + 1;

        zones(index, :) = [x, y, zoneWidth, zoneHeight];
        index = index + 1;
    end
end
end