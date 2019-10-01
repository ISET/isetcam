function rgb = lrgb2srgb(rgb)
% Convert linear sRGB values to proper sRGB values
%
%    rgb = lrgb2srgb(rgb)
%
% This routine implements the nonlinear step for converting linear rgb
% (lrgb) into the frame buffer representations in the srgb representation.
% The rgb data can be in either RGB or XW format.
%
% The inputs are linear rgb values, and the returned values are nonlinear
% framebuffer values. They are in the range [0,1] 
%
% The  gamValue used in the srgb formula combines with a linear regime that
% makes an overall approximation of the display gamma as 2.4
%
% Previous web references have been deleted from this file because the
% links are now dead.  The proper link is to the Wikipedia srgb page.
%
% Reference: Wikipedia sRGB page
%
% See also:  xyz2srgb, srgb2lrgb
%
% Copyright ImagEval Consultants, LLC, 2005.

if (max(rgb(:)) > 1 || min(rgb(:)) < 0)
    error('Linear rgb values must be between 0 and 1'); 
end

% These are framebuffer values, but they live in [0,1]. The transformation,
% which has a linear and power part, is intended to approximate a gamma of
% 2.2 as a whole. 
big = (rgb > 0.0031308);
rgb(~big) = rgb(~big) * 12.92;
rgb(big) = 1.055*rgb(big).^(1/2.4) - 0.055;

end
