function im = recons_steerable_pyramid_full(pyr, filt_num)

[ht wth nbands] = size(pyr);
pyr = pyr(:);
pind = [0 0; repmat([ht wth], [nbands 1])];
nlevels = round((nbands-1)/filt_num)-1;
im = reconFullSFpyr2_o(pyr, pind, nlevels, filt_num, 1, 0);