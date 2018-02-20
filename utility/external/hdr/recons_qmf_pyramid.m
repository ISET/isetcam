function [res] = recons_qmf_pyramid(pyr, qmf_length)

% [res] = recons_qmf_pyramid(pyr, qmf_length)
% reconstructs an image from a non-decimated qmf pyramid
% built using [pyr] = qmf_pyramid(pic, nlevels, qmf_length)
% qmf_length can be 9 or 13, and has to be consistent with 
%    the qmf_length used to build the pyramid
% Yuanzhen Li (yzli@mit.edu), Dec 2004

ht = size(pyr, 1);
wth = size(pyr, 2);
nlevels = size(pyr, 3);

lowpass_prev = pyr(:,:,nlevels);
nlevel_idx = nlevels;
band_idx = nlevels-1;

if (nargin < 2)
    qmf_length = 9;
end
qmf_halflen = floor((qmf_length/2));

if qmf_length == 9
    filt_low = [0.02807382 -0.060944743 -0.073386624 0.41472545 0.7973934 0.41472545 -0.073386624 -0.060944743 0.02807382]/sqrt(2);
    filt_high = modulateFlip(filt_low)'; %[0.02807382 +0.060944743 -0.073386624 -0.41472545 0.7973934 -0.41472545 -0.073386
elseif qmf_length == 13
    filt_low = [-0.014556438 0.021651438 0.039045125 -0.09800052 ...
            -0.057827797 0.42995453 0.7737113 0.42995453 -0.057827797 ...
            -0.09800052 0.039045125 0.021651438 -0.014556438]/sqrt(2);
    filt_high = modulateFlip(filt_low)';
end

nlevels = floor(nlevels/3);
for ii = nlevels:-1:1
    if (ii == 1)
        extend_space = qmf_halflen;
        nspace = 1;
    else
        extend_space = qmf_halflen*(2^(ii-1));
        nspace = 2^(ii-1);
    end
    extend_lo_lo = pad_reflect(lowpass_prev, extend_space);
    extend_hi_hi = pad_reflect(pyr(:,:,band_idx), extend_space);
    band_idx = band_idx-1;
    extend_hi_lo = pad_reflect(pyr(:,:,band_idx), extend_space);
    band_idx = band_idx-1;
    extend_lo_hi = pad_reflect(pyr(:,:,band_idx), extend_space);
    band_idx = band_idx-1;
    [ext_ht, ext_wth] = size(extend_lo_lo);
    
    lo_lo_row = zeros(ext_ht, wth);
    hi_hi_row = zeros(ext_ht, wth);
    hi_lo_row = zeros(ext_ht, wth);
    lo_hi_row = zeros(ext_ht, wth);
    start = 1;
    for mm = 1:qmf_length
        lo_lo_row = lo_lo_row + extend_lo_lo(:,start:start-1+wth)*filt_low(mm);
        hi_hi_row = hi_hi_row + extend_hi_hi(:,start:start-1+wth)*filt_high(mm);
        hi_lo_row = hi_lo_row + extend_hi_lo(:,start:start-1+wth)*filt_high(mm);
        lo_hi_row = lo_hi_row + extend_lo_hi(:,start:start-1+wth)*filt_low(mm);
        start = start + nspace;
    end
    
    start = 1;
    lo_lo = zeros(ht, wth);
    lo_hi = zeros(ht, wth);
    hi_lo = zeros(ht, wth);
    hi_hi = zeros(ht, wth);
    for mm = 1:qmf_length
        lo_lo = lo_lo + lo_lo_row(start:start-1+ht,:)*filt_low(mm);
        lo_hi = lo_hi + lo_hi_row(start:start-1+ht,:)*filt_high(mm);
        hi_lo = hi_lo + hi_lo_row(start:start-1+ht,:)*filt_low(mm);
        hi_hi = hi_hi + hi_hi_row(start:start-1+ht,:)*filt_high(mm);
        start = start + nspace;
    end
    
    lowpass_prev = lo_lo+lo_hi+hi_lo+hi_hi;
end

res = lowpass_prev;