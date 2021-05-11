function imT = imageLinearTransform(im, T)
% Apply a linear transformation to the color channels of an RGB format image
%
%  imT = imageLinearTransform(im,T)
%
% The image data (im) are in N x M X W format, (e.g., W=3 if RGB or W = 31
% if the wavelength samples are 400:10:700). The routine applies a right
% side multiply to the data. Specifically, if an image point is represented
% by the row vector, p = [R,G,B] the matrix transforms each color point, p,
% to an output vector pT.  In this case, T has 3 rows.
%
% If the data are viewed as wavelength samples, say [w1,w2,...wn], then the
% transform T must have n rows.
%
% This routine works with colorTransformMatrix, which provides access to
% various standard color transformation matrices.
%
% This routine works with im in the format (N x M x W) and a T matrix size
% (W x K), where K is the number of output channels.
%
% Example:
%   Returns an NxMx3 xyz Image
%     T = colorTransformMatrix('lms2xyz');
%     xyzImage = imageLinearTransform(lmsImage,T);
%
%     T = ipGet(vci,'displayspd');
%     spectralImage = imageLinearTransform(lmsImage,T);
%
% See Also: colorTransformMatrix
%
% Copyright ImagEval Consultants, LLC, 2003.

% Save out the image size information
[r, c, w] = size(im);

if size(T, 1) ~= w
    error('image/T data sizes are incorrect. If im is RGB, size(T,1) must be 3.');
end

% We reshape the image data into a r*c x w matrix
%
im = RGB2XWFormat(im);

% Then we multiply and reformat.
imT = im * T;
imT = XW2RGBFormat(imT, r, c);

return
