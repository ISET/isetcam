function T = sensorDisplayTransform(sensor)
%
% Synopsis
%
%  T = sensorDisplayTransform(sensor)
%
% Inputs:
%  sensor - ISETCam sensor
%
% Optional key/val pairs
%  N/A
%
% Output
%   T - Matrix that converts the N channels in the sensor to RGB values
%
% Description
%   Find a transform that maps the sensor filter spectra into a an
%   approximation of their (R,G,B) appearance. This transform is used for
%   displaying the sensor data.
%
%   To see estimate the RGB appearance of the filterSpectra, we create
%   block matrix functions and multiply the filterspectra
%
%      filterRGB = bMatrix'*filterSpectra
%
%   The first column of filterRGB tells us the RGB value to use to display
%   the first filter, and so forth.  So, if the sensor data are in the
%   columns of a matrix, we want the display image to be
%
%                   sensorData*filterRGB'
%
%   Also, we want to scale T reasonably.  For now, we have [1,1,1]*T set to
%   a max value of 1.  But these images look a little dim to me.
%
% See also
%   sensorData2Image, sensorDemosaic
%

% We set the extrapVal to 0.2 because we may have infrared data
bMatrix = colorBlockMatrix(sensorGet(sensor,'wave'),0.2);
filterSpectra = sensorGet(sensor,'filterspectra');

filterRGB = bMatrix'*filterSpectra;
T = filterRGB';
% o = ones(1,size(T,1));
s = max(T(:));
% s = max((o*T)');
T = T/s;

end
