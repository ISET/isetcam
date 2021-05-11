function htimage = HalfToneImage(cell, im)
%
%            htimage = HalfToneImage(cell, im)
%
% AUTHOR:  Koehler, Zhang, Wandell
% DATE:    02.25.97
% PURPOSE:
%
% This function takes in a halftone cell and an image as
% arguments.
%    cell: An array of threshold levels.  If these exceed 1, then
%          the cell is scaled to evenly spaced values between 0 and 1.
%          If the numbers all fall between 0 and 1, then they are
%          left as they are.
%    im:   The image gray levels, values between 0 and 1.
%
% htimage: The returned halftone image.  Its values are set to 0
% (white) or 1 (black).  The binary color map is [ 1 1 1; 0 0 0];

% DEBUGGING:
% im = (rand(32,32)).^2;
% cell = [ 1 2 ; 3 4];

imSize = size(im);
cellSize = size(cell);

% The cell thresholds should fall at the midpoints of the
%
if max(cell) > 1
    low = (1 / max(cell(:))) * 0.5;
    high = 1 - low;
    halfToneCell = ieScale(cell, low, high);
else
    halfToneCell = cell;
end

% Determine number of halftone cells needed to cover the image
%
rc = imSize ./ cellSize;
r = ceil(rc(1));
c = ceil(rc(2));

% Builds an image that covers the original and whose entries
% contain the values of the halfToneCell repeated, again and again.
halfToneMask = kron(ones(r, c), halfToneCell);

% Crop out that part of the mask equal in size to the image.
halfToneMask = halfToneMask(1:imSize(1), 1:imSize(2));

% Compare the image intensity at each point to the value in the
% halftone mask.  If the image density exceeds the mask we use
% a 1, otherwise a 0.
htimage = (halfToneMask < im);

return;

% DEBUGGING
% colormap([1 1 1; 0 0 0])
% subplot(1,2,1)
% imagesc(im), axis image
% subplot(1,2,2)
% imagesc(htimage), axis image
