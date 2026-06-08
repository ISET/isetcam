% s_Raw2ISET
%
% Create ISET sensor image from raw sensor data
%   You will be ask to provide the following information about your raw
%   sensor data
%       Bits/pixel (8 or 10)
%       Byte format (big or little endian)
%       Number of pixels in the rows and columns
%       Color filter array pattern
%           bayer-bggr
%           bayer-rggb
%           bayer-grbg
%           bayer-gbrg

% You can test this script using raw data available at
%            www.imageval/public/Products/ISET/download/RawSensorData/DeviceA_and_B
%   The data are:
%       Two files from Device A ('DeviceA_MCC.raw' and 'DeviceA_ISO.raw') have
%           10 bit data
%           Byte Format is big endian
%           row = 2048,  col = 1536
%           Color filter array (cfa) is 'bayer-gbrg'
%       Two files from Device B ('DeviceB_MCC.raw' and 'DeviceB_ISO.raw') have
%           8 bit data
%           Byte Format does not matter (use default setting in the menu selections)
%           row = 2048,  col = 1536
%           Color filter array (cfa) is 'bayer-grbg'

% UTTBSkip

%%
fullName = vcSelectDataFile('stayput','r','raw','Select *.raw file');
if isempty(fullName), return; end

prompt={'Bits per pixel (8/10):','Format (big or little) endian','row','col','CFA'};
name = 'Read raw image data';
numlines=1;
defaultanswer={'10','big',num2str(2048),num2str(1536),'bayer-gbrg'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
bpp = str2double(answer{1}); format = answer{2};
row = str2double(answer{3}); col = str2double(answer{4});
cfa = answer{5};

%%
mosaic = LoadRawSensorData(fullName,bpp,format,row,col);

mosaic  = double(reshape(mosaic,row,col));
mosaic = mosaic/max(mosaic(:));  % Normalize to 0-1

% The image is big.  So, we usually crop.
[mosaic2,rect] = imcrop(mosaic);
rect = round(rect);

% Adjust the rect so we fall neatly on the bayer sampling grid.
% We want the (xmin,ymin) values to both be odd.
if ~isodd(rect(1)), rect(1)=rect(1)+1; end
if ~isodd(rect(2)), rect(2)=rect(2)+1; end

% We want the (width,height) values to both be even.  Matlab's imcrop
% basically adds one more pixel than you want.  So, annoyingly, we must
% make the width and height odd, so we get an even number of pixels out.
if ~isodd(rect(3)),  rect(3)=rect(3)+1; end
if ~isodd(rect(4)),  rect(4)=rect(4)+1; end

% You can choose from four RGB sensor types
% sensor = sensorCreate('bayer-bggr');
% sensor = sensorCreate('bayer-rggb');
% sensor = sensorCreate('bayer-grbg');
% sensor = sensorCreate('bayer-gbrg');
sensor = sensorCreate(cfa);

% Set pixel parameters
pixel  = sensorGet(sensor,'pixel');
pixel  = pixelSet(pixel,'widthandheight',[2.2,2.2]*10^-6);
vSwing = pixelGet(pixel,'voltageSwing');
sensor = sensorSet(sensor,'pixel',pixel);

% Set the color filter spectral curves here, when you have them.
% sensor = sensorSet(sensor,'expTime',info.ExposureTime);

% Attach the volts to the sensor
volts    = imcrop(mosaic,rect)*vSwing;
sensor   = sensorSet(sensor,'size',size(volts));
sensor   = sensorSet(sensor,'volts',volts);

% Save out the sensor file.  This is the file you can load from the
% ISET-Sensor window using the method described at the top of the file.
fullName = vcExportObject(sensor,[],0);

%% Now, run ISET
% Open the Sensor window
% Click on the File menu (left top in the sensor window
% Select Load > Sensor
% Select the Sensor.mat file
% The data should appear in the sensor window
% You can now open the Processor window and process this image

%%