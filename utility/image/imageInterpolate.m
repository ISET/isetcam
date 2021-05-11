function img = imageInterpolate(inImg, r, c)
% Resample the data in inImg to a row and col size.
%
%  img = imageInterpolate(inImg,r,c)
%
%  The interpolation routine works on spectral images, too.
%
%  This routine uses imresize from the Matlab image processing toolbox on
%  each plane of the RGB format image, inImg.
%
% Example.
%   scene = vcGetObject('scene');
%   r = sceneGet(scene,'rows');
%   c = sceneGet(scene,'cols');
%   photons = imageInterpolate(sceneGet(scene,'photons'),r,c);
%   imageSPD(photons);
%
% Copyright ImagEval Consultants, LLC, 2003.

% Programming Note:
%   Use imresize instead of the code below.  It is much faster and it is invertible!
%   XDING.
%   B = IMRESIZE(A,[MROWS MCOLS],METHOD)
%   B = IMRESIZE(A,M,METHOD)
%   Hmmm.   It doesn't appear to be invertible.

if ieNotDefined('r'), error('Must specify new row size.'); end
if ieNotDefined('c'), error('Must specify new col size.'); end
if ieNotDefined('inImg'), error('Input image required.'); end

[r0, c0, w] = size(inImg);
img = zeros(r, c, w);

% Either use scale form or row,col form for the image
if (r / r0 == c / c0), s = r / r0;
else s = [r, c];
end

% We could pass in the method as an argument, and not always use bilinear.
for ii = 1:w
    img(:, :, ii) = imresize(inImg(:, :, ii), s, 'bilinear');
end

return;
