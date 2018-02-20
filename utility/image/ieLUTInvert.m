function lut = ieLUTInvert(inLUT,resolution)
% Calculate an inverse lookup table (lut) at a specified sampling resolution
%
%    lut = ieLUTInvert(inLUT,resolution)
%
% inLUT:      A gamma table that converts linear DAC values to linear RGB.
% resolution: The display bit depth is log2(size(DAC,1)).  We are going to
%   make an inverse table with finer resolution.  
%
% lut:  The returned lookup table.
% If resolution = 2, then we have twice the number of levels in the
% returned table.
%
% Example:
%   d = displayCreate;
%   inLUT = d.gamma.^0.6;
%   lut = ieLUTInvert(inLUT,3);
%   vcNewGraphWin; plot(lut)
%
% See also:  ieLUTDigital, ieLUTLinear
%
% (c) Imageval Consulting, LLC 2013

if ieNotDefined('inLUT'), error('input lut required'); end
if ieNotDefined('resolution'), resolution = 0.5; end

x = 1:size(inLUT,1);
y = inLUT(:,1);
% Check for monotonicity
if ~all(diff(y(:))>0) %numeric first derivative
    % Not monotonic increasing.  So we need to adjust.  This can happen
    % when we have several equal values.  To handle this we make a string
    % of really small values that are increasing (one part in a million)
    % and add them to every term.  Then the terms that are equal differ a
    % little.
    s = ((1:length(y))/length(y))*1e-9;
    y = y(:) + s(:);
end

nbits = log2(length(y));
m = 2^nbits - 1;
iY = (0:(1/resolution):m)/(2^nbits);
lut = interp1(y(:),x(:),iY(:),'PCHIP',m);

end
