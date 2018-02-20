function [coefScaleFactor, compressionFactor] = makeQTable(halfMax)
%
% AUTHOR: B. Wandell
% DATE: 10.20.94
%
% PURPOSE:
% Make a quantization table for the JPEG quantization
% step.  The formula is based on cutting down the number of bits
% as a function of distance from the origin.  The function can be
% made to fall off more or less quickly based on the halfMax parameter.
%

%x = 1:128;
%plot(x ./ (x + halfMax));

nBits = zeros(8,8);
for i=1:8
 for j=1:8
%  nBits(i,j) = 8 - (i^2 + j^2)^0.5;
   d = i^2 + j^2;
  nBits(i,j) = 8 -  ( (8*d) / (d + halfMax));
 end
end
ma = mmax(nBits);
mn = mmin(nBits);
nBits = round( 8* (nBits - mn) ./ (ma - mn));
compressionFactor = 512/sum(sum(nBits));
coefScaleFactor = 2 .^ (nBits - 8);
