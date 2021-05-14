function dataXYZ = imageRGB2XYZ(ip,RGB)
% Convert values in an RGB Format data into XYZ values (also RGB Format)
%
%   dataXYZ = imageRGB2XYZ(ip,RGB)
%
% The conversion from RGB to XYZ accounts for the characteristics
% of the display represented in ip (image processor). RGB must be
% in XW format (space-wavelength).
%
% This routine assumes that the RGB values are 'linear' primary
% intensities and that any gamma correction will be applied
% elsewhere.
%
% Perhaps this routine should be inside of imageDataXYZ.
%
% Example:
%   See plotDisplayColor
%
% See also:  imageDataXYZ, ieXYZFromEnergy
%
% Copyright ImagEval Consultants, LLC, 2003.

%% Argument checking and set input data format flag
if ~(ismatrix(RGB))
    % XW format is a matrix.  RGB format is not.
    % If you are here, we are RGB format.
    [RGB, row, col]= RGB2XWFormat(RGB);
    RGBFlag = 1;
else, RGBFlag = 0;
end

%% Calculate
spd  = ipGet(ip,'display rgb spd');
wave = ipGet(ip,'display wave');

% The display value is always in the unit cube.  Even if the sensor data
% are quantized, we maintain the data in the unit cube. The RGB values are
% always relative to the maximum control variable in the display.  So,
% RGB/rgbMax is a number between 0 and 1 defining how much the particular
% primary is excited, relative to the maximum value.  Hence, the spd of the
% primaries are the measurements when the primary is at maximum intensity.
energy = RGB*spd';

dataXYZ = ieXYZFromEnergy(energy,wave);

%% Return the right format
if RGBFlag
    dataXYZ = XW2RGBFormat(dataXYZ,row,col);
end

end
