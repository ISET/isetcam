function [pyr] = haar_pyramid(pic, nlevels)

% [pyr] = haar_pyramid(pic, nlevels)
% builds oversampled haar pyramid
% Input:
%   pic is the input image;
%   nlevels is the number of scales;
% Output:
%   pyr: oversampled haar pyramid, containing 3*nlevels+1 subbands
%    the last one being the lowpass.
% Yuanzhen Li (yzli@mit.edu), Dec 2004

ht = size(pic,1);
wth = size(pic,2);

lowpass_prev = pic;
nband = 1;

for ii = 1:nlevels
    extend_space = max(1, 2^(ii-2));
    nspace = 2^(ii-1);
    extend = pad_reflect(lowpass_prev, extend_space);

    if ii > 1
        shift_1 = extend(1:ht, 1:wth);
        shift_2 = extend(1:ht, 1+nspace: wth+nspace);
        shift_3 = extend(1+nspace:ht+nspace, 1:wth);
        shift_4 = extend(1+nspace:ht+nspace, 1+nspace:wth+nspace);
    else
        shift_1 = extend(2:ht+1, 2:wth+1);
        shift_2 = extend(2:ht+1, 2+nspace: wth+1+nspace);
        shift_3 = extend(2+nspace:ht+1+nspace, 2:wth+1);
        shift_4 = extend(2+nspace:ht+1+nspace, 2+nspace:wth+nspace+1);
    end

    lowpass_prev = (shift_1 + shift_2 + shift_3 + shift_4)/4;
    pyr(:,:,nband) = (shift_1 + shift_2 - shift_3 - shift_4)/4;
    nband = nband+1;
    pyr(:,:,nband) = (shift_1 - shift_2 + shift_3 - shift_4)/4;
    nband = nband+1;
    pyr(:,:,nband) = (shift_1 - shift_2 - shift_3 + shift_4)/4;
    nband = nband+1;
    clear extend
end

pyr(:,:, nband) = lowpass_prev;