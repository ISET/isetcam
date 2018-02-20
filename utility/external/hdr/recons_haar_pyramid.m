function [pic] = recons_haar_pyramid_new(pyr)

% [pic] = recons_haar_pyramid_new(pyr)
% reconstructs the non-decimated haar pyramid
% pyr: 3*nlevels+1 subbands
% built using [pyr] = haar_pyramid(pic, nlevels)
% Yuanzhen Li (yzli@mit.edu), Dec 2004

[ht, wth, nbands] = size(pyr);

band_idx = nbands - 1;
lowpass_prev = pyr(:,:,nbands);
nlevels = floor(nbands/3);

for ii = nlevels:-1:1
    nspace = 2^(ii-1);
    extend_space = floor(nspace/2);
    if ii==1
        extend_space = 1;
    end
    extend_low = pad_reflect(lowpass_prev, extend_space);
    extend_3 = pad_reflect_neg(pyr(:,:,band_idx), extend_space, extend_space, 1, 1);
    band_idx = band_idx - 1;
    extend_2 = pad_reflect_neg(pyr(:,:,band_idx), extend_space, extend_space, 1, 0);
    band_idx = band_idx - 1;
    extend_1 = pad_reflect_neg(pyr(:,:,band_idx), extend_space, extend_space, 0, 1);    
    band_idx = band_idx - 1;

    shift_1_1 = 1:ht;
    shift_1_2 = 1:wth;
    shift_2_2 = 1+nspace: wth+nspace;
    shift_3_1 = 1+nspace:ht+nspace;
    lowpass_prev = (extend_low(shift_1_1, shift_1_2) + extend_low(shift_1_1, shift_2_2) ...
        + extend_low(shift_3_1, shift_1_2) + extend_low(shift_3_1, shift_2_2));
    band_1 = (- extend_1(shift_1_1, shift_1_2) - extend_1(shift_1_1, shift_2_2) ...
        + extend_1(shift_3_1, shift_1_2) + extend_1(shift_3_1, shift_2_2));
    band_2 = (- extend_2(shift_1_1, shift_1_2) + extend_2(shift_1_1, shift_2_2) ...
        - extend_2(shift_3_1, shift_1_2) + extend_2(shift_3_1, shift_2_2));
    band_3 = (extend_3(shift_1_1, shift_1_2) - extend_3(shift_1_1, shift_2_2) ...
        - extend_3(shift_3_1, shift_1_2) + extend_3(shift_3_1, shift_2_2));
    lowpass_prev = (lowpass_prev + band_1 + band_2 + band_3)/4;
end

pic = lowpass_prev;
