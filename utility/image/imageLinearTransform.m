function imT = imageLinearTransform(im, T)
% Apply a linear transformation to the channels of an RGB or XW image 
%
% Syntax:
%   imT = imageLinearTransform(im, T)
%
% Description:
%    The image data (im) can be in the N x M X W format, (e.g., W = 3
%    if RGB or W = 31 if the wavelength samples are 400:10:700). The
%    routine applies a right side multiply to the data. Specifically,
%    if an image point is represented by the row vector, p = [R, G, B]
%    the matrix transforms each color point, p, to an output vector
%    pT. In this case, T has 3 rows.
%
%    The image can also be in XW format, in which case the transform
%    is applied as XW * T, where T is expressed as a column vector.
%
%    If the data are viewed as wavelength samples, say [w1, w2, ...wn], 
%    then the transform T must have n rows.
%
%    This routine works with colorTransformMatrix function (see
%    Example), which provides access to various standard color
%    transformation matrices.
%
%    This routine works with im in the format (N x M x W) and a T matrix
%    size (W x K), where K is the number of output channels.  It also
%    works with an im in XW format, again with T in (W x K) format.
%
%    Examples within the code can be accessed by typing 'edit
%    imageLinearTransform.m' into the Command Window.
%
% Inputs:
%    im  - The original image, in N x M x W format or XW format.
%    T   - The transform to act upon the image.
%
% Outputs:
%    imT - The transformed image
%
% Optional key/value pairs:
%    None.
%
% See Also:
%    colorTransformMatrix, RGB2XWFormat
%

% History:
%    xx/xx/03       Copyright ImagEval Consultants, LLC, 2003.
%    12/07/17  jnm  Formatting & change example
%    12/26/17   BW  Added XW format handling
%    01/26/18  jnm  Formatting update to match the Wiki.

% Examples:
%{
    % Returns an N x M x 3 xyz Image
    XYZ = ieReadSpectra('XYZ.mat', 370:730);
    imXYZ = zeros(361, 20, 3);
    for ii = 1:3
        imXYZ(:, :, ii) = repmat(XYZ(:, ii), 1, 20);
    end
    T = colorTransformMatrix('xyz2srgb');
    imRGB = imageLinearTransform(imXYZ, T);
    imagescRGB(imRGB);
%}
%{
    % Same operation for XW format input
    XYZ = ieReadSpectra('XYZ.mat', 370:730);
    imXYZ = zeros(361, 20, 3);
    for ii = 1:3
        imXYZ(:, :, ii) = repmat(XYZ(:, ii), 1, 20);
    end
    [imXYZ,r,c] = RGB2XWFormat(imXYZ);
    T = colorTransformMatrix('xyz2srgb');
    imXW = imageLinearTransform(imXYZ, T);

    imRGB = XW2RGBFormat(imXW,r,c);
    imagescRGB(imRGB);
%}

%% Determine image format to convert to XW

% Not sure why, but ismatrix() did not work here.
if ndims(im) == 3 || ((ndims(im) == 2) && (size(T,1) == 1)) %#ok<ISMAT>
    iFormat = 'RGB';
    % Save  the image row/col information
    [r, c, w] = size(im);
    
    % Reshape the image data into a (r * c) x w format (XW)
    im = RGB2XWFormat(im);
else
    iFormat = 'XW';
    [~, w] = size(im);
end
if size(T, 1) ~= w, error('image/T data sizes mismatch'); end

%% We multiply and reformat back to RGB if necessary
imT = im * T;
if isequal(iFormat,'RGB'), imT = XW2RGBFormat(imT, r, c); end

end