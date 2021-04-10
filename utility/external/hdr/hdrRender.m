function [res] = hdrRender(im, filt_type, s_sat, bbeta, aalpha, ifsharp)
% Compress the dynamic range of an HDR image
%
% [res] = hdrRender(im, filt_type(optional), s_sat(optional), 
%           beta(optional), alpha(optional), ifsharp (optional))
%
% Reference: Yuanzhen Li, Lavanya Sharan, Edward H. Adelson. Compressing
%     and Companding High Dynamic Range Images with Subband Architectures.
%     ACM Transactions on Graphics (TOG), 24(3), Proceedings of SIGGRAPH
%     2005.
%
% Dynamic range compression with subband architectures, for color images.
%
% Yuanzhen Li (yzli@mit.edu), 06/2006
%
% This function was called range_compression().
% Renamed for clarity as part of ISET by Imageval.
%
% Input:
%  im is the input image, can be color or grayscale.
%  filt_type (optional, default='haar') specifies the type of filters.
%     It can be 'haar', 'qmf', or 'steerable'.
%  s_sat (optional) is a parameter controlling how much color desaturation
%   is needed, so as to make colors of the range compression result look
%   natural. Default: 0.7. If the input is a grayscale image, this
%   parameter doesn't matter.
%  beta (optional, default=0.6) and alpha (optional, default=0.2)
%    specify the level of compression, smaller beta and/or smaller alpha
%    give greater compression.
%  ifsharp (optional) when set to 1 gives the result a sharper look, but the
%    result is more subject to halo artifacts. Default is 0, which gives
%    smoother looking result with minimal artifacts.
%
% calls the following function:
%        [res] = range_compression_lum(pic, beta(optional), alpha_A(optional), 
%                   beta(optional), alpha(optional), filt_type(optional))
%  refer to it for more info about beta, alpha, filt_type, and more details
%     about the algorithm.
%
%
% Incorporated into ISET distribution, March 1, 2014.
% The code has not been materially changed.  I added a few
% comments for clarity, modified the name, and checked for 'var' in the
% exist function. 

% Input arguments
if ~exist('s_sat','var'),     s_sat = 0.7; end
if ~exist('bbeta','var'),     bbeta = 0.6; end
if ~exist('aalpha','var'),    aalpha = 0.2; end
if ~exist('filt_type','var'), filt_type = 'haar'; end
if ~exist('ifsharp','var'),   ifsharp = 0;        end

% parameters
prc_loend = 2; prc_hiend = 99;
if size(im,3) == 1
    % grayscale image
    res = range_compression_lum(im, filt_type, bbeta, aalpha, ifsharp);
else
    % color image
    % first compute the chromaticities of the original HDR image:
    im_lum = rgb2hsv(im);
    im_lum = im_lum(:,:,3);
    r_ratio = im(:,:,1)./(im_lum+1e-9);
    g_ratio = im(:,:,2)./(im_lum+1e-9);
    b_ratio = im(:,:,3)./(im_lum+1e-9);

    % do range compression on the luminance:
    res_lum = range_compression_lum(im_lum, filt_type, bbeta, aalpha, ifsharp);

    % color adjustment
    res_lum = im_norm(res_lum);
    res(:,:,1) = res_lum.*(r_ratio.^s_sat);
    res(:,:,2) = res_lum.*(g_ratio.^s_sat);
    res(:,:,3) = res_lum.*(b_ratio.^s_sat);
end

% cut off the brightest and darkest parts:
low_end = prctile(res(:), prc_loend);
high_end = prctile(res(:), prc_hiend);
res = (res-low_end)/(high_end-low_end);
res = min(1, res);
res = max(0, res);

% we find a trick can often make the result "open up" a bit, the trick 
% being adding 15% of a histogram equalized layer to the result. 
res = im_norm(final_touch(res));


%% END