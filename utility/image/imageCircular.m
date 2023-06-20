function im = imageCircular(im)
% Pull out a circular image region from the center
%
% Synopsis
%   im = imageCircular(im)
%
% Brief description
%   By default, the radius is equal to half the image size.  Some day, put
%   in a radius parameter
%
% Input
%  im - A monochrome image array
%
% Output
%  im - the circular central region of the image array
%
% See also
%   wvfPupilAmplitude

imageSize = size(im);
centerPoint = [imageSize/2 + 1, imageSize/2+1];
radius = (imageSize - 1)/2;

[X,Y] = meshgrid((1:imageSize) - centerPoint(1),(1:imageSize) - centerPoint(2));
imRadius = sqrt(X.^2 + Y.^2);
% ieNewGraphWin; imagesc(imRadius); colormap(gray); colorbar; axis image

idx = (imRadius > radius);
im(idx) = 0;
% ieNewGraphWin; imagesc(im); colormap(gray); colorbar; axis image

end