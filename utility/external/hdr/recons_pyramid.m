function [im] = recons_pyramid(pyr, filt_num, filt_type)

% [im] = recons_pyramid(pyr, filt_num, filt_type)
% reconstructs an image from a non-decimated pyramid

if strcmp(filt_type, 'haar')
    im = recons_haar_pyramid(pyr);
elseif strcmp(filt_type, 'qmf')
    im = recons_qmf_pyramid(pyr);
elseif strcmp(filt_type, 'steerable')
    im = recons_steerable_pyramid_full(pyr, filt_num);
else
    error('filt_type can only be "haar", "qmf", or "steerable"..');
end
