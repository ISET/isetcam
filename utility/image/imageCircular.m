function im = imageCircular(im)
% Pull out a circular image region from the center
%
% Synopsis
%   im = imageCircular(im)
%
% Brief description
%   By default, the radius is equal to half the minimum image size dimension.  Some day, put
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

% The radius is related to the image size
%
% DHB: Thy=is was previously written with the vector imageSize passed to
% meshgrid. Matlab 2024 starting throwing a warning that this doesn't make
% sense. I changed to pass imageSize(1) and imageSize(2) as the args
% to meshgrid, and simplified calculation of centerPoint on the assumption
% that imageSize is in fact a vector. Also, I used 2 as the index for the
% x arg to meshgrid, and 1 as the index for the y arg.  This was the other
% way around for centerPoint previously, but I think that is wrong.
imageSize   = size(im);
if (length(imageSize) ~= 2)
    error('Need to think about what to do if someone passes a vector as an image');
end
  
centerPoint = imageSize/2 + 1;
radius = (min(imageSize) - 1)/2;

[X,Y] = meshgrid((1:imageSize(2)) - centerPoint(2),(1:imageSize(1)) - centerPoint(1));
imRadius = sqrt(X.^2 + Y.^2);
% ieNewGraphWin; imagesc(imRadius); colormap(gray); colorbar; axis image

% Zero out the values beyond the radius
idx = (imRadius > radius);
im(idx) = 0;
% ieNewGraphWin; imagesc(im); colormap(gray); colorbar; axis image

end
