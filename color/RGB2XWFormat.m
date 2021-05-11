function [XW, r, c, w] = RGB2XWFormat(imRGB)
% Transform an RGB form matrix into an XW (space-wavelength) matrix
%
%   [XW,r,c,w] = RGB2XWFormat(imRGB)
%
% This  routine converts from RGB format to XW format.  The row and
% column of the imRGB are also returned, if requested.
%
% We say matrices in (r,c,w) format are in RGB format.  The dimension, w,
% represents the number of data color bands.  When w=3, the data are an RGB
% image. But w can be almost anything (e.g., 31 wavelength samples from
% 400:10:700).  We use this format frequently for spectral data.
%
% The RGB format is useful for imaging.  When w = 3, you can use
% conventional image() routines.  When w > 3, use imageSPD.
%
% The XW (space-wavelength) format is useful for computation.  In this
% format, for example, XW*spectralFunction yields a spectral response.
%
% The inverse routine is XW2RGBFormat
%
% See also, imageSPD, imagescRGB, imagescM, XW2RGBFormat
%
% Copyright ImagEval Consultants, LLC, 2003.

s = size(imRGB);

% If the data are in a matrix, then assume only one wavelength dimension,
% (row,col,1).
if length(s) < 3
    s(3) = 1;
end

XW = reshape(imRGB, s(1)*s(2), s(3));

r = s(1);
c = s(2);
w = s(3);

return;
