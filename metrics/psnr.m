function val = psnr(im1, im2)
%
%   val = psnr(im1,im2)
%
%Author: ImagEval
%Purpose:
%  Measure the peak signal-to-noise ratio (PSNR) between a pair of images.
%  This is a rough quality measure.  Very rough.  Very low quality.
%
% Internet information: http://www.vsofts.com/codec/codec_psnr.html

se = (255 * (im1 - im2)).^2;
rmse = sqrt(mean(se(:)));

if rmse == 0
    val = Inf;
else
    val = 20 * log10(255/sqrt(rmse));
end

return;
