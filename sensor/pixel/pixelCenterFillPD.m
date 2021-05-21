function sensor = pixelCenterFillPD(sensor,fillfactor)
% Adjust the pixel photodiode to be centered (fill factor [0,1])
%
%    sensor = pixelCenterFillPD(sensor,fillfactor)
%
% Create a centered photodetector with a particular fill factor within a
% pixel. (The pixel is attached to the sensor.)
%
% Example:
%  sensor = pixelCenterFillPD(sensor,0.5)
%
% See also: pixelPositionPD
%
% Copyright ImagEval Consultants, LLC, 2003.

% Programming notes:
%   This function should probably be written for the pixel, not the isa.
%
%      pixel = pixelCenterFillPD(pixel,fillfactor);
%
%  Also, changes in the size of the pixel within the GUI preserve the
%  fillfactor.

if ieNotDefined('sensor'), sensor = vcGetObject('ISA'); end
if ieNotDefined('fillfactor'), fillfactor = 1;
elseif (fillfactor > 1) || (fillfactor < 0)
    error('Fill factor must be between 0 and 1.  Parameter value = %f\n',fillfactor);
end

pixel = sensorGet(sensor,'pixel');

% Adjust pixel photodetector position to center with specified fill factor
% We define the fill factor as being the proportion of photodetector within
% the (pixel plus the gap), not just the pixel.
pixel = pixelSet(pixel,'pd width',sqrt(fillfactor)*pixelGet(pixel,'deltax'));
pixel = pixelSet(pixel,'pd height',sqrt(fillfactor)*pixelGet(pixel,'deltay'));

% Center the pixel and return
sensor = sensorSet(sensor,'pixel',pixelPositionPD(pixel,'center'));

return;
