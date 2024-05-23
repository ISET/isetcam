function val = iePSNR(im1,im2)
% Suggest using the Matlab version (psnr) in the image processing toolbox
%
%   val = iePSNR(im1,im2)
%
% Brief:
%  Measure the peak signal-to-noise ratio (PSNR) between a pair of images.
%  This is a rough quality measure. Widely, and badly, used.
%
% Internet information: http://www.vsofts.com/codec/codec_psnr.html
%
% See also
% {'/Applications/MATLAB_R2023b.app/toolbox/images/images/psnr.m'                      }
% {'/Applications/MATLAB_R2023b.app/toolbox/images/deep/@dlarray/psnr.m'               }
% 
se = (255*(im1 - im2)).^2;
rmse = sqrt(mean(se(:)));

if rmse == 0
    val = Inf;
else
    val = 20*log10(255/sqrt(rmse));
end

return;
