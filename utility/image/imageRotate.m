function imT = imageRotate(im, rotType)
% Rotate image data - CW or CCW
%
%   imT = imageRotate(im,rotType)
%
% The image data, im, size(im) = (r,c,w) can have any value for w.
% imT contains the data from im, but each color plane is rotated.
%
% We treat rotType = CW or CCW (ClockWise and CounterClockwise) as special
% cases, using rot90.
%
% If rotType is a number we call imrotate.  Not sure this works properly on
% all data.  This feature is not yet used in ISET (I think).
%
% Example:
%   imT = imageRotate(im,'cw');
%   imT = imageRotate(im,'ccw');
%   imT = imageRotate(im,30);
%
% Copyright ImagEval Consultants, LLC, 2009

if ndims(im) ~= 3, error('Input must be rgb image (row x col x w)'); end
if ieNotDefined('rotType'), rotType = 'ccw'; end

if isnumeric(rotType)
    tmp = imrotate(im(:, :, 1), rotType, 'bilinear', 'loose');
    [r, c, w] = size(tmp); clear tmp
    imT = zeros(r, c, w);
    for ii = 1:size(im, 3)
        imT(:, :, ii) = imrotate(im(:, :, ii), rotType, 'bilinear', 'loose');
    end
else
    [r, c, w] = size(im);
    imT = zeros(c, r, w);
    switch lower(rotType)
        case {'cw', 'clockwise'}
            for ii = 1:size(im, 3)
                imT(:, :, ii) = rot90(im(:, :, ii), -1);
            end
        case {'ccw', 'counterclockwise'}
            for ii = 1:size(im, 3)
                imT(:, :, ii) = rot90(im(:, :, ii), 1);
            end
    end
end

return;