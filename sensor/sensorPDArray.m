function pdArray = sensorPDArray(sensor, spacing)
%Measure percent photodetector area within an ISA region
%
%  pdArray = sensorPDArray(sensor,spacing)
%
% Warning:  This routine seems obsolete or at least in need of checking.
%
% Create an array that measures the percentage of area of the
% photodetector contained within each square in a grid spanning the pixel
% locations.  The code is used as part of the spatialIntegration
% calculation.
%
% The spacing indicates the fineness of the grid on a unit region (i.e.,
% 1 is the center-to-center spacing between pixels.
%
% This code assumes the shape of the photodetector is row-col separable
% (i.e. a rectangle or square).
%
% When spacing ==1, this is the same as the pixel fill factor (0,1).
%
% See also:  spatialIntegration
%
% Copyright ImagEval Consultants, LLC, 2003.

if spacing > 1 | spacing < 0
    error('The spacing parameter exceeds the limit.  It must be between 0 and 1, typically less than 0.25');
end

PIXEL = sensorGet(sensor, 'PIXEL');
pixelSize = pixelGet(PIXEL, 'size');

% Find the boundaries of the photodetector position.  These units are
% normalized so that we effectively have a set of squares running frrom
% 0:1:(1/spacing)
normalizedPdMin = pixelGet(PIXEL, 'pdPosition') ./ (spacing * pixelSize);
normalizedPdMax = (pixelGet(PIXEL, 'pdSize') + pixelGet(PIXEL, 'pdPosition')) ./ (spacing * pixelSize);

% Now, quantize the pixel according to the spacing
gridPositions = [0:spacing:1] / spacing;
nSquares = length(gridPositions) - 1;
inPDRows = zeros(1, nSquares);
inPDCols = inPDRows;
for ii = 1:nSquares
    % I haven't checked if I have rows/cols in the right order.
    lower = max(gridPositions(ii), normalizedPdMin(1));
    upper = min(gridPositions(ii + 1), normalizedPdMax(1));
    inPDRows(ii) = max(0, upper-lower);

    lower = max(gridPositions(ii), normalizedPdMin(2));
    upper = min(gridPositions(ii + 1), normalizedPdMax(2));
    inPDCols(ii) = max(0, upper-lower);
end

% We assume the pd size is row-col separable.
pdArray = inPDRows' * inPDCols;

return;
