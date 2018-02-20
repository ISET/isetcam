% ReadMe.m
%
% Dynamic range compression with subband architectures. 
%
% The algorithm implemented here is described in: 
%     Yuanzhen Li, Lavanya Sharan, Edward H. Adelson. Compressing and 
%     Companding High Dynamic Range Images with Subband Architectures.
%     ACM Transactions on Graphics (TOG), 24(3), Proceedings of 
%     SIGGRAPH 2005.
%
% Please email any comment or report any bug to:
% Yuanzhen Li (yzli@mit.edu), 
% http://web.mit.edu/yzli/www/
%
% 
% The main function for range compression ("range_compression.m")
% It takes as input a grayscale or a color high dynamic range image, and
% returns as output the range-compressed version.
% Refer to "range_compression.m" for details about parameter settings. 
% We find the default parameter setting works quite well for most images 
% we've experimented with.
% 
% There are several variations of the algorithm, and implemented here is 
% the version using spatially oversampled pyramids, and gain map derived 
% from a single activity map aggregated from all the subbands.
%
%
% Referred code from others:
% filt_type can be 'haar', 'qmf', or 'steerable', and the 'steerable'
% option calls routines from Eero Simoncelli's MatlabPyrTools toolbox,
% which is availble at http://www.cns.nyu.edu/~eero/software.html
% Please install this toolbox first if you plan to use the 'steerable'
% option. The current package also contains routines modified from some
% contained in the above toolbox, and some in the BLS-GSM Image Denoising 
% Toolbox authored by Javier Portilla (http://decsai.ugr.es/~javier/).
%
%
%
% An example using the default parameter setting:
%
% load a high dynamic range image, in the format of .pfm
im_name = 'chairs.pfm';  
% this hdr image is from the Columbia CAVE lab.
im = getpfmraw(im_name);
% performs dynamic range compression
res = range_compression(im);
% save the result
imwrite(res, strcat(im_name(1:length(im_name)-4), '.png'), 'bitdepth', 16);
%
%
% Another example using user-set parameters:
%
% load a high dynamic range image, in the format of .pfm
im_name = 'doll_small.pfm';  
% the full-sized hdr doll picture can be downloaded from:
% http://web.mit.edu/persci/yzli/doll_hdr/doll_doll.hdr
im = getpfmraw(im_name);
% performs dynamic range compression
filt_type = 'haar';
res = range_compression(im, filt_type, 0.7, 0.6, 0.2, 1);
% save the result
imwrite(res, strcat(im_name(1:length(im_name)-4), '_', filt_type, '.png'), 'bitdepth', 16);
%
