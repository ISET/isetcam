function RGB = SRGBGammaCorrect(rgb,SCALE)
% RGB = SRGBGammaCorrect(rgb,[SCALE])
%
% Gamma correct according to sRGB standard.
% 
% SCALE = 0: No scaling applied to input rgb.  Input values > 1 truncated to 1.
% SCALE = 1: Input data scaled to max of 1.  (Default).
% 
% Input values less than 0 are truncated to zero.
%
% The gamma correction stage of the SRGB standard converts inputs in the
% range [0,1] into gamma corrected output in the same range.
%
% This routine then multiplies the [0,1] output by 255 and quantizes
% to integer values.  None-the-less, it still returns the output as
% a double (rather than uint8) matrix.  I (DHB) am not sure this was
% a good design decision, but am for now (6/15/11) leaving it as is
% to avoid breaking code that relies on the current implementation.
% [Smarter, I think would have been to return values in the [0,1] range
% and leave the quantization to the caller, or else to convert to uint8
% after scaling into [0,255].]
%
% See XYZToSRGBPrimary for comment on evolution of the standard
% and of this implementation.
%
% 5/1/04    dhb             Wrote it.
% 7/8/10    dhb             Updated to match standard I can now find on the web.
% 6/15/11   dhb, ms         Clarify input output range issues in comment.

% Set SCALE if not passed.
if (nargin < 2 || isempty(SCALE))
	SCALE = 1;
end

% Scale into range, or truncate to 1.
if (SCALE)
	rgb = rgb/max(rgb(:));
else
	index = find(rgb > 1);
	if (~isempty(index))
		rgb(index) = 1;
	end
end

% Truncate negative values to 0.
index = find(rgb < 0);
if (~isempty(index))
	rgb(index) = 0;
end

% Cutoff value
% Value in old routines was 0.0031308, which I actually think
% was wrong even for the old standard.  It should have been
% 0.00405 for the old standard.
cutoff = 0.00304; 

% Apply sRGB gamma correction according to formulae
rgbprime = rgb;
index = find(rgb < cutoff);
if (~isempty(index))
	rgbprime(index) = 12.92*rgb(index);
end
index = find(rgb >= cutoff);
if (~isempty(index))
	rgbprime(index) = 1.055*(rgb(index).^(1/2.4))-0.055;
end
clear rgb;

% Quantize to 8 bits.
RGB = round(255*rgbprime);

