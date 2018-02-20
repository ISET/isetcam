function [pyr, filt_num] = build_pyramid(im, nlevels, filt_type)

% [pyr, filt_num] = build_pyramid(im, nlevels, filt_type)
% builds a non-decimated pyramid from an image

if strcmp(filt_type, 'haar')
    pyr = haar_pyramid(im, nlevels);
    filt_num = 3; 
elseif strcmp(filt_type, 'qmf')
    filt_num = 3;
    pyr = qmf_pyramid(im, nlevels);
elseif strcmp(filt_type, 'steerable')
    filt_num = 4; 
    pyr = steerable_pyramid_full(im, nlevels-1, filt_num);
else
    error('filt_type can only be "haar", "qmf", or "steerable"..');
end
