function rgb = SRGBGammaUncorrect(RGB)
% rgb = SRGBGammaUncorrect(RGB)
%
% Undo standard sRGB gamma correction, taking [0-255] -> [0-1].
%
% See XYZToSRGBPrimary for comment on evolution of the standard
% and of this implementation.
%
% See comments inn XYZToSRGBPrimary for info on standard.
%
% 2/9/06	dhb	 Wrote it.
% 7/8/10    dhb  Rewrote to match current standard.
% 8/16/10   dhb  Fix typo in header.

% Apply sRGB gamma correction according to formulae
cutoff = 0.03928;
RGB = double(RGB)/255;
rgb = RGB;
index = find(RGB < cutoff);
if (~isempty(index))
	rgb(index) = RGB(index)/(12.92);
end
index = find(rgb >= cutoff);
if (~isempty(index))
    rgb(index) = (((RGB(index))+0.055)/1.055).^2.4;
end


