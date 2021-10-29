function [sensorPlane, sensor] = sensorRGB2Plane(rgbData,  cfaPattern)
% Convert multiple band color data into a sensor plane representation
%
%   [sensorPlane, sensor] = sensorRGB2Plane(rgbData, cfaPattern)
%
% This routine is the inverse of plane2rgb.
%
% Inputs
%  rgbData:  (r,c,w) color data
%  cfaPattern:  Small matrix indicating the positions of the filters in
%               each block
% Returns:
%  sensorPlane:  Returned sensor plane data, drawn from the rgbData
%
% The rgbData is an (m x n x w) matrix filled with sensor values.  These
% might have been created, say, by looping through a set of monochrome
% sensors each with its own color filters. We convert the RGB format data
% into a sensor plane (cfa) by selecting data base don the pattern of the
% sensor color filters in the sensor structure.
%
% Specifically, each sensor has a CFA structure determined by the
% cfaPattern variable.  We  call sensorDetermineCFA to figure out which
% positions in the sensor plane have which filters.  We fill the planar
% array (sensorPlane) with the data from the rgbData (multiple band).
%
% Example:
%    rgbData = rand(16,16,4);
%    cfaPattern = [ 1 2 3 4; 3 4 2 1];
%    sensorPlane = sensorRGB2Plane(rgbData, cfaPattern);
%    vcNewGraphWin; imagesc(sensorPlane)
%
% See also:  plane2rgb
%
% (c) Imageval 2012

if ieNotDefined('rgbData'), error('rgb data required'); end
if ieNotDefined('cfaPattern'), error('cfaPattern required'); end

[r,c,nBands] = size(rgbData);
if max(cfaPattern) > nBands, error('bad cfa pattern'); end

% Following makes sure the sensor ends after a complete CFA block.  If not
% there are errors later in this function.  This also makes sure the sensor
% is smaller than the rgbData so that rgbData can be cropped to the
% appropriate size.
r = size(cfaPattern,1) * floor(r/size(cfaPattern,1));
c = size(cfaPattern,2) * floor(c/size(cfaPattern,2));
rgbData = rgbData(1:r, 1:c, :);

% Dummy up a sensor
sensor = sensorCreate;
sensor = sensorSet(sensor,'volts',[]);

% Make up the fake filters and filter names for the sensor
fNames = sensorColorOrder;
fNames = fNames(1:nBands);
filt   = ones(sensorGet(sensor,'nwave'),nBands);

% Set up the dummy sensor - which can be returned
sensor = sensorSet(sensor,'cfa pattern',cfaPattern);
sensor = sensorSet(sensor,'size',[r,c]);
sensor = sensorSet(sensor,'filter spectra',filt);
sensor = sensorSet(sensor,'filter names',fNames);

% This is an array of letters in each sensor position
CFAletters = sensorDetermineCFA(sensor);

% Loop on the color bands, extracting the rgbData from each band and the
% relevant locations.
sensorPlane = zeros(r,c);
for ii=1:nBands
    tmp = rgbData(:,:,ii);
    thisBand = (CFAletters == fNames{ii});
    sensorPlane(thisBand) = tmp(thisBand);
end
% imagesc(sensorPlane)

return