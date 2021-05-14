function outImage = changeColorSpace(inImage,colorMatrix)
%OBSOLETE: Change an image color space by matrix multiplication.
%
% outImage = changeColorSpace(inImage,colorMatrix)
%
% The input image is either an RGB image (m x n x 3) or an XW image but with 3 columns.
% For backwards compatibility the routine also works on an inImage that is
% a single matrix built from R,G,B, images as
%
%		inImage = [ R G B];
%
% The output image is returned in the same format as the input.
%
% The calculation converts the data into an Nx3 matrix and right multiplies
% the data with a 3 x 3 color matrix.  That is, the matrix converts column
% vectors in the input image representation into column vectors in the
% output representation.
%
%    outImage =   [ inImage ] * colorMatrix'
%    Note the TRANSPOSE:  ***EEEK**** Why we shouldn't use any more.
%
% where inImage is converted to XW format.
%
% TODO: Made some progress on this - July 2011:
% S-CIELAB code uses changeColorSpace and the old routine, cmatrix,
% rather than the new routines, colorTransformMatrix and
% imageLinearTransform.  I haven't changed S-CIELAB over yet.  But it
% should be changed to use imageLinearTransform and colorTransformMatrix,
% and then changeColorSpace and cmatrix should be eliminated from the
% archive.
%
% To make these changes will require changing a few routines in the scielab
% directory.
%

insize = size(inImage);

% We put the pixels in the input image into the rows of a very
% large matrix
%
inImage = reshape(inImage, prod(insize)/3, 3);

% We post-multiply by colorMatrix' to convert the pixels to the output
% color space
%
outImage = inImage*colorMatrix';

% Now we put the output image in the basic shape we use
%
outImage = reshape(outImage, insize);

return;
