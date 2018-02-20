function [large] = pad_reflect(im, xsize, ysize)

% reflect the edges

if (nargin < 3)
    ysize = xsize;
end

ht = size(im, 1);
wth = size(im, 2);

large = [im(ysize+1:-1:2, xsize+1:-1:2), im(ysize+1:-1:2, :), ...
        im(ysize+1:-1:2, wth-1:-1:wth-xsize); ...
        im(:, xsize+1:-1:2), im, im(:, wth-1:-1:wth-xsize); ...
        im(ht-1:-1:ht-ysize, xsize+1:-1:2), ...
        im(ht-1:-1:ht-ysize, :), ...
        im(ht-1:-1:ht-ysize, wth-1:-1:wth-xsize)];
