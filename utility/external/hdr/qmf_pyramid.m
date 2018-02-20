function [pyr] = qmf_pyramid(pic, nlevels, qmf_length)

% [pyr] = qmf_pyramid(pic, nlevels, qmf_length(optional))
% builds oversampled qmf pyramid
% Input:
%   pic is the input image;
%   nlevels is the number of scales;
%   qmf_length(optional) is the number of taps of the qmf filter, 
%      which can be 9 or 13. Default is 9.
% Output:
%   pyr: oversampled qmf pyramid, containing 3*nlevels+1 subbands
%    the last one being the lowpass.
% Yuanzhen Li (yzli@mit.edu), Jan 2004
% calls modulateFlip.m from Eero Simoncelli's matlab pyramid toolbox 
%   "matlabPyrTools". http://www.cns.nyu.edu/~lcv/software.html

ht = size(pic,1);
wth = size(pic,2);

lowpass_prev = pic;
nband = 1;
if ( nargin < 3)
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
else
    error('qmf_length can only be 9 or 13..');
end

for ii = 1:nlevels
    if (ii == 1)
        extend_space = qmf_halflen;
        nspace = 1;
    else
        extend_space = qmf_halflen*(2^(ii-1));
        nspace = 2^(ii-1);
    end
    extend = pad_reflect(lowpass_prev, extend_space);
    [ex_ht, ex_wth] = size(extend);
    
    plus_filt = filt_low(1:2:qmf_length);
    minus_filt = filt_low(2:2:qmf_length);

    plus_len = length(plus_filt);
    minus_len = length(minus_filt);
    
    plus_row = zeros(ex_ht, wth);
    minus_row = zeros(ex_ht, wth);
    plus_col_low = zeros(ht, wth);
    minus_col_low = zeros(ht, wth);
    plus_col_hi = zeros(ht, wth);
    minus_col_hi = zeros(ht, wth);

    start = 1;
    for mmm = 1:plus_len
        plus_row = plus_row + extend(:, start:start-1+wth)*plus_filt(mmm);
        start = start + nspace*2;
    end    
    start = 1+nspace;
    for mmm = 1:minus_len
        minus_row = minus_row + extend(:, start:start-1+wth)*minus_filt(mmm);
        start = start + nspace*2; 
    end
    
    lowpass_row = plus_row + minus_row;
    hipass_row = plus_row - minus_row;
    
    start = 1;
    for mmm = 1:plus_len
        plus_col_low = plus_col_low + lowpass_row(start:start-1+ht, :)*plus_filt(mmm);
        plus_col_hi = plus_col_hi + hipass_row(start:start-1+ht, :)*plus_filt(mmm);
        start = start + nspace*2;
    end
    start = 1+nspace;
    for mmm = 1:minus_len
        minus_col_low = minus_col_low + lowpass_row(start:start-1+ht, :)*minus_filt(mmm);
        minus_col_hi = minus_col_hi + hipass_row(start:start-1+ht, :)*minus_filt(mmm);
        start = start + nspace*2;
    end
    
    lowpass_prev = plus_col_low + minus_col_low;
    pyr(:,:,nband) = plus_col_low - minus_col_low ;
    nband = nband + 1;
    pyr(:,:,nband) = plus_col_hi + minus_col_hi;
    nband = nband + 1;
    pyr(:,:,nband) = plus_col_hi - minus_col_hi;
    nband = nband + 1;
    clear extend
end

pyr(:,:, nband) = lowpass_prev;