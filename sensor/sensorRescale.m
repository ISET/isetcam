function sensor = sensorRescale(sensor,rowcol,sensorHeightWidth)
% Adjust the pixel size to accomodate new size, fixed dye
%
%     newsensor = sensorRescale(sensor,rowcol,sensorHeightWidth)
%
% *** Generally, avoid this routine unless you really know what you are doing ***  
%  
% In this method, the pixel dimensions are adjusted to accomodate the new
% sensor row/col, and pixel width/height (meters). 
%   
% Current data are cleared because they are incompatible with the 
% re-scaled pixel and sensor parameters.
%
% Example:
%  sensor = vcGetObject('sensor');
%  pixel = sensorGet(sensor,'pixel');  pixelGet(pixel,'size','microns')
%  sensor = sensorRescale(sensor,sensorFormats('qqcif'),sensorFormats('quarterinch'));
%  pixel = sensorGet(sensor,'pixel');  pixelGet(pixel,'size','microns')
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('sensorHeightWidth'), error('Sensor height/width must be defined.');  end
pixel = sensorGet(sensor,'pixel');

% No gap between the pixels
pixel = pixelSet(pixel,'widthGap',0);
pixel = pixelSet(pixel,'heightGap',0);

% The new pixel size is chosen to match the sensor dimension and the number
% of rows and columns.  
pixel.width = sensorHeightWidth(2)/rowcol(2);
pixel.height = sensorHeightWidth(1)/rowcol(1);

%The photodetector is chosen to have a fifty percent fill factor and it is
%placed in the center of the pixel 
pixel = pixelSet(pixel,'pdwidth',sqrt(.5)*pixelGet(pixel,'width'));
pixel = pixelSet(pixel,'pdheight',sqrt(.5)*pixelGet(pixel,'height'));
newArea = pixelGet(pixel,'pdarea');

pixel = pixelPositionPD(pixel,'center');

% Put the pixel back, clear the data, and return
sensor.pixel = pixel;

sensor = sensorClearData(sensor);

return;