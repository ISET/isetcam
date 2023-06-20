function boundingBox = ieBoundingBox(image)
% Bounding box of a cirle
%
% Synopsis
%
% See also
%

% Examples:
%{
image = zeros(100);
centerX = 50;
centerY = 50;
radius = 30;
[X, Y] = meshgrid(1:size(image, 2), 1:size(image, 1));
circle = ((X - centerX).^2 + (Y - centerY).^2) <= radius^2;
image(circle) = 1;

% Calculate the square bounding box
boundingBox = ieBoundingBox(image);
%}

    % Find the indices of non-zero elements (1s) in the image
    [row, col] = find(image);

    % Calculate the minimum and maximum row and column indices
    minRow = min(row);
    maxRow = max(row);
    minCol = min(col);
    maxCol = max(col);

    % Calculate the center coordinates of the circular region
    centerX = (minCol + maxCol) / 2;
    centerY = (minRow + maxRow) / 2;

    % Calculate the maximum difference between center and edge in row and column directions
    maxDiff = max(abs(maxRow - centerY), abs(maxCol - centerX));

    % Calculate the coordinates of the square bounding box
    boundingBox = [centerX - maxDiff, centerY - maxDiff, 2 * maxDiff, 2 * maxDiff];
end


