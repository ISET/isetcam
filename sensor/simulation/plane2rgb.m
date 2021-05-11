function [rgbFormat, cfaVals] = plane2rgb(img, sensor, emptyVal)
%Converts a sensor data plane into a (row,col,color) RGB format image
%
%   [rgbFormat, cfaVals] = plane2rgb(img,sensor,[emptyVal])
%
%  This  routine is  part of demosaicking algorithms. This routine converts
%  data from a sensor plane that contains interleaved color representation
%  (m x n x 1) into a RGB format in which every color dimension is in a
%  different 3rd dimension (m x n x w).
%
% img:      The vcimage input field, which is typically the the data field
%           from the sensor.
% sensor:   The sensor containing a description of the wavebands. The
%           number of color planes is equal to the number of different
%           color sensors.
% emptyVal: default is NaN. In the RGB format the unfilled values are all
%           set to emptyVal.
%
% Returns:
%
%  In the returned image each plane represents one color in the color
%  filter array (cfa).  For example, if the input img is (row,col) and
%  contains red, green and blue pixels, the returned rgbFormat is (row,col,3)
%  with each of the image planes containing the red, green or blue data
%  values.
%
%  Empty (unfilled) color entries in the returned matrix are assigned the
%  value 'emptyVal'. The default is emptyVal = NaN.
%
%  The cfaVals is a list of characters of the color filter names.  It is
%  the same as the first letters in the cell array returned by
%  sensorGet(sensor,'filterString')
%
% See also:  sensorRGB2Plane
%
% Example:
%   rgbFormat = plane2rgb(img,sensor,0);
%   rgbFormat = plane2rgb(img,sensor);  imagescRGB(rgbFormat);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('img'), error('img required - img is the vci input field'); end
if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('emptyVal'), emptyVal = NaN; end

% nFilters    = sensorGet(sensor,'nfilters');
% filterNames = sensorGet(sensor,'filterNames');

% The cfa has numbers indicating indicating the color filter at each
% position in the plane.
%
% [tmp,cfa] = sensorDetermineCFA(sensor);
%
% The returned values in cfa are letters that define the color of the
% filter. These are derived from the first letter of the filterName strings
% in sensor.
%
% The cfaN values are the  number corresponding to the letter in the
% pre-defined colororder string string (sensorColorOrder). In this case,
% wherever there is a red filter the band number is 1.  If the sensor
% contains, say, g, c, w then the numbers will be 2 4 7.
[cfa, cfaN] = sensorDetermineCFA(sensor);

% This is a string of single letters identifying
filterColorLetters = sensorGet(sensor, 'filterColorLetters');

% The output has one plane for each color filter in the sensor.
nPlanes = length(filterColorLetters);
rows = size(img, 1);
cols = size(img, 2);
rgbFormat = zeros(rows, cols, nPlanes);

% For pixel binning or other digital value cases, we may have the digital
% value array size differ from the voltage size.  So we need to clip the
% cfa and cfaN arrays to be the same as the digital value array size.
if ~isequal(size(img), size(cfa))
    cfa = cfa(1:rows, 1:cols);
    cfaN = cfaN(1:rows, 1:cols);
end

% Place the data for each color filter array in the plane that corresponds
% to its column entry in filterSpectra.  For example, if the filter spectra
% are in RGB format, then plane 1 is R, plane 2 is G and plane 3 is B.  If
% the filters are in GRB format, then 1 is G, 2 is R and 3 is B.
for ii = 1:nPlanes

    % Set the image plane all to the default value
    tmp = ones(rows, cols) * emptyVal;

    % Find the locations for the first of the values
    % filterColorLetters is the list of color letters for the color
    % filters.  It might be 'rgbg'
    % l = (filterColorLetters(ii) == cfa);
    l = (cfaN == ii);

    % Set the entries at those locations to img(l)
    tmp(l) = img(l); % figure(1); hist(tmp(:),50)

    % Place the data in tmp into the appropriate location of rgbFormat
    % Here, we make sure that if the data are cmy the order of the planes
    % is cym.  We need to be more aggressive in checking here.  As it
    % stands, this code works only because sensorColorOrder has the right
    % ordering (cym, and rgb).
    % So, for example, this doesn't work quite right with the four color
    % ordering.
    % Not yet implemented ... but on the short to do list.
    % I think the right algorithm is to place the data into the color plane
    % that corresponds to its filter.  So, if the g filter is in the first
    % column, then the g data should be in rgbFormat(:,:,1).
    rgbFormat(:, :, ii) = reshape(tmp, rows, cols);
    % figure(1); imagesc(rgbFormat(1:6,1:6,ii)); colormap(gray)
end

% The function unique sorts the results so that we now know which color
% filters we have in the image sensor plane.
if nargout > 1, cfaVals = unique(cfaN(:)); end

end