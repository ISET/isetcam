function ret = FloydSteinberg(FS, image)
% FloydSteinberg error diffusion
%
%   ret = FloydSteinberg(FS, image)
%
% This algorithm applies the error matrix specified by the
% input matrix FS to image.  FS will be normalized to 1
% and is assumed to be 0 at and to the left of the pixel
% being processed.  (This will be the pixel in the middle
% of the top row).  The image returned is screened to black
% and white.

% determine the size of the image and the FS matrix for processing

[img_r, img_c] = size(image);
xFS_r = size(FS, 1);
xFS_c = fix(size(FS, 2)/2);

% and create a temporary matrix with columns at the sides of the
% image to catch the overflow at the ends.  (Note, you could choose
% to drop the error at the ends and just work directly on the image.)

temp = zeros(img_r+xFS_r, img_c+2*xFS_c);
temp(1:img_r, xFS_c+1:xFS_c+img_c) = image;

% Now process each pixel.  Errors at the two ends will be accumulated
% "down and to the right" or "up and to the left."  This happens in the
% extra columns and is processed as the count nears the right end of
% each row.  The overflow columns are blanked after the error is
% applied to keep from double counting.

for ir = 1:img_r,

    for ic = xFS_c + 1:img_c,
        error = temp(ir, ic);
        temp(ir, ic) = round(error);
        error = error - temp(ir, ic);
        error_mat = error * FS;
        temp(ir:ir+xFS_r-1, ic-xFS_c:ic+xFS_c) = ...
            temp(ir:ir+xFS_r-1, ic-xFS_c:ic+xFS_c) + error_mat;
    end

    temp(ir:ir+xFS_r-1, img_c+1:img_c+xFS_c) = ...
        temp(ir:ir+xFS_r-1, img_c+1:img_c+xFS_c) + temp(ir+1:ir+xFS_r, 1:xFS_c);

    for ic = img_c + 1:img_c + xFS_c,
        error = temp(ir, ic);
        temp(ir, ic) = round(error);
        error = error - temp(ir, ic);
        error_mat = error * FS;
        temp(ir:ir+xFS_r-1, ic-xFS_c:ic+xFS_c) = ...
            temp(ir:ir+xFS_r-1, ic-xFS_c:ic+xFS_c) + error_mat;
    end

    temp(ir+1:ir+xFS_r, xFS_c+1:2*xFS_c) = ...
        temp(ir+1:ir+xFS_r, xFS_c+1:2*xFS_c) + temp(ir:ir+xFS_r-1, ...
        img_c+xFS_c+1:img_c+2*xFS_c);

    temp(:, 1:xFS_c) = zeros(img_r+xFS_r, xFS_c);
    temp(:, img_c+xFS_c+1:img_c+2*xFS_c) = zeros(img_r+xFS_r, xFS_c);

end

ret = temp(1:img_r, xFS_c+1:xFS_c+img_c);

return;
