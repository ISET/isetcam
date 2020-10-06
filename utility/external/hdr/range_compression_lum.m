function [res] = range_compression_lum(pic, filt_type, beta, alpha_A, ifsharp)
% [res] = range_compression_lum(pic, filt_type(optional), beta(optional), alpha_A(optional), ifsharp(optional))

% Dynamic range compression with subband architectures. 
%  An input image is decomposed into subbands, which are rectified, blurred, 
%  and summed to give an activity map. A gain map is derived from the 
%  activity map using: gain = activity^(beta-1).*alpha^(1-beta), where 
%  beta and alpha are to be specified. Each subband coefficient is then
%  multiplied by the gain at that point, and the modified subbands are 
%  post-filtered and summed to reconstruct the result image.
% Input:
% pic (grayscale) is the input image.
% filt_type (optional) specifies the type of filters. It can be 'haar',
%      'qmf', or 'steerable'. Default: 'haar'.
% beta (optional) is the power term used to derive gain from subband 
%       activity: gain = activity^(beta-1).*alpha^(1-beta). Default: 0.6.
% alpha_A (optional) is used to compute the alpha in the above gain
%       formula: alpha = alpha_A*mean(activity), which can be interpreted
%       as a compression/expansion threshold. Default: 0.2.
%       Smaller beta and/or smaller alpha_A give greater compression.
% ifsharp (optional) when set to 1 gives the result a sharper look, but the
%       result is more subject to halo artifacts. Default is 0, which gives
%       smoother looking result with minimal artifacts.

% Reference: Yuanzhen Li, Lavanya Sharan, Edward H. Adelson. Compressing 
%     and Companding High Dynamic Range Images with Subband Architectures.
%     ACM Transactions on Graphics (TOG), 24(3), Proceedings of SIGGRAPH
%     2005.

% Yuanzhen Li (yzli@mit.edu), 06/2006

if ~exist('beta')
    beta = 0.6;
end
if ~exist('alpha_A')
    alpha_A = 0.2;
end
if ~exist('filt_type')
    filt_type = 'haar';
end
if ~exist('ifsharp')
    ifsharp = 0;
end
epsilon = 0.002;

% take the log
im = log((pic/mean(pic(:)))+1e-6);
im = im - min(im(:));

% decompose the log image into an oversampled haar pyramid
nlevels = floor(log2(min(size(im))))-3;
[pyr, filt_num] = build_pyramid(im, nlevels, filt_type);
[ht,wth,pyr_nlayer] = size(pyr);
lowpass = pyr(:,:,pyr_nlayer);

% compute the lowpass activity map:
width_init = 4; 
width = 65; 
gauss = fspecial('gaussian', [1 width], width/2); 
extend = pad_reflect(abs(lowpass), floor(width/2));
lowpass_blur = conv2(gauss, gauss', extend, 'valid');

% aggregate activity maps from all subbands
band_blur_sum = zeros(ht,wth,nlevels);
band_blur_sum_sum = zeros(ht,wth);
for i = 1:nlevels
    width = width_init*2^(i-1)+1; 
    extend_space = round((width-1)/2);
    gauss = fspecial('gaussian', [1 width], width/2);
    temp = 0;
    for j = 1:filt_num
        band_idx = (i-1)*(filt_num-1)+j;
        extend = pad_reflect(abs(pyr(:,:,band_idx)), extend_space);
        temp = temp + extend;        
    end
    band_blur_sum(:,:,i) = conv2(gauss, gauss', temp, 'valid');
    band_blur_sum(:,:,i) = band_blur_sum(:,:,i)/filt_num;
end
weights = ones(nlevels, 1);
for jj = 1:length(weights)
    band_blur_sum_sum = band_blur_sum_sum + weights(jj)*band_blur_sum(:,:,jj);
end
% including the lowpass
band_blur_sum_sum = (band_blur_sum_sum+lowpass_blur)/(sum(weights)+1);

% compute a single gain map from the aggregated activity map:
alpha = median(band_blur_sum_sum(:))*alpha_A;
gain = ((band_blur_sum_sum+epsilon).^(beta-1)).*((alpha)^(1-beta));
% apply the single gain map to all subbands, with different weights to
% different spatial frequencies:
endrate = 0.6;
if ifsharp == 1
    endrate = 0.4;
end
for ii = 1:pyr_nlayer
    level_here = floor((ii-1)/filt_num)+1;
    gain_amount = max(1-(level_here-1)*0.15, endrate);
    pyr(:,:,ii) = pyr(:,:,ii).*gain*gain_amount;
end

% reconstruct the result image from the pyramid:
pyr = real(pyr);
res = recons_pyramid(pyr, filt_num, filt_type);
res = exp(res);
clear pyr