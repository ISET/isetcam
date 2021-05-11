function imT = imageTranspose(im)
% Transpose image data in multispectral or RGB
%
%   imT = imageTranspose(im)
%
%  The transpose applies to multispectral data with size(im) = (r,c,w)
%  where w can be any value. imT is the same data with each of the color
%  planes transposed.
%
% see also:  imageFlip
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('im'), error('Image required.'); end
if ndims(im) ~= 3
    error('Input must be 3-dimensional: row x col x w');
end
[r, c, w] = size(im);
imT = zeros(c, r, w);
for ii = 1:size(im, 3)
    imT(:, :, ii) = im(:, :, ii)';
end

return;
