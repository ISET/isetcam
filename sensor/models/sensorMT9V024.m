function sensor = sensorMT9V024(~,colorType)
%% Create the ON MT9V024 model, based on the data sheet
%
% Internal to sensorCreate.  Loads the relevant sensors that were saved out
% by another function
%
% Copyright Imageval, LLC 2017
%
% See also
%   isetcam/data/sensor/auto for the MT9V024Create.m

% 480 x 752 pixels
% 6 um pixels
% 60 FPS
% 10 bit
% Responsivity 4.8 V/lux-sec at 550 nm
% 3.3 V (voltage swing, only accurate to 0.3 V)
% 55 dB linear dynamic range
% 100 dB HDR mode
% 2x2 and 4x4 binning are available.

%{
pixelSize  = 6*1e-6; % Big pixels.  And they can be binned!
fillFactor = 0.9;  % Assuming back side illuminated
sensorSize = [480 752];    % Not important, really, but OK
voltageSwing = 3.3;
%}

% Let's check this.  From the spec sheet
% responsivity = 4.8;  % volts/lux-sec

%% Create and set parameters

switch colorType
    case 'mono'
        name = 'MT9V024SensorMono';
        
    case 'rgb'
        % GB/RG
        name = 'MT9V024SensorRGB';
        
    case 'rccc'
        % Three white and one red
        name = 'MT9V024SensorRCCC';
        
    case 'rgbw'
        % Three white and one red
        name = 'MT9V024SensorRGBW';
        
    otherwise
        error('Unknown type %s\n',colorType);
end

sensorFile = fullfile(isetRootPath,'data','sensor','auto',name);
load(sensorFile,'sensor');

end
