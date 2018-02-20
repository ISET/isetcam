function pyr = steerable_pyramid_full(im, nlevels, filt_num)

[ht wth] = size(im);
[pyr_vtr,pind] = buildFullSFpyr2_o(im, nlevels, filt_num-1, 1, 0);
nbands = filt_num*(nlevels+1)+1;
pyr = reshape(pyr_vtr, [ht wth nbands]);