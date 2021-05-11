function imRGB = XW2RGBFormat(imXW, row, col)
% Convert XW format data to RGB format
%
%    imRGB = XW2RGBFormat(imXW,row,col);
%
%   This  routine converts from XW format to RGB format.  The row and
%   column of the imXW are required input arguments.
%
%   We say matrices in (r,c,w) format are in RGB format.  The dimension, w,
%   represents the number of data color bands.  When w=3, the data are an RGB
%   image. But w can be almost anything (e.g., 31 wavelength samples from
%   400:10:700).  We use this format frequently for spectral data.
%
%   The RGB format is useful for imaging.  When w = 3, you can use
%   conventional image() routines.  When w > 3, use imageSPD.
%
%   The XW (space-wavelength) format is useful for computation.  In this
%   format, for example, XW*spectralFunction yields a spectral response.
%
%   The inverse routine is RGB2XWFormat.
%
% See also: imageSPD, imagescRGB, imagescM, RGB2XWFormat
%
% Copyright ImagEval Consultants, LLC, 2003.


if ~exist('imXW', 'var') || isempty(imXW), error('No image data.'); end

% I took this out because it is possible to have a monochrome scene with
% just one column.
% if ndims(imXW) ~= 2,  error('XW2RGB:  input should be 2D'); end

if ~exist('row', 'var') || isempty(row), error('No row size.'); end
if ~exist('col', 'var') || isempty(col), error('No col size.'); end

x = size(imXW, 1);
w = size(imXW, 2);

if row * col ~= x, error('XW2RGBFormat:  Bad row, col values'); end

imRGB = reshape(imXW, row, col, w);

return;
