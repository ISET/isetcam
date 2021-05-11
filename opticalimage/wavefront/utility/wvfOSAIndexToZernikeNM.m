function [n, m] = wvfOSAIndexToZernikeNM(j)
% [n,m] = wvfOSAIndexToZernikeNM(j)
%
% Convert the OSA single Zernike index (starting at j = 0) to the Zernike
% 2-index standard indexing.
%
% n is radial order
% m is angular frequency
%
% Uses equations 5 and 6 from the OSA numbering document
%
% j can be a vector, in which case so are m and n.
%
% See also: wvfOSAIndexToVectorIndex, wvfOSAIndexToZernikeNM, zernfun
%
%  DHB:  (c) Wavefront Toolbox Team, 2013

% Radial order n
n = ceil((-3+sqrt(9 + 8 * j))/2);
m = 2 * j - n .* (n + 2);

return

%% Validation code
j = 1:100;
[n, m] = wvfOSAIndexToZernikeNM(j);
jCheck = wvfZernikeNMToOSAIndex(n, m);
if (any(jCheck ~= j))
    error('Zernike index conversion routines do not invert properly');
end
