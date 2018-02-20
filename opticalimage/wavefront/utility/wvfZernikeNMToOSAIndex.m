function j = wvfOSAIndexToZernikeMN(n,m)
% j = wvfOSAIndexToZernikeMN(n,m)
%
% Convert from the Zernike 2 index standard indexing
% to the OSA single Zernike index (starting at j = 0)
% 
% n is radial order
% m is angular frequency
%
% Uses equation 4 from the OSA numbering document
% 
% j can be a vector, in which case so are n and m.
%
% See also wvfZernikeNMToOSAIndex, zernfun
%
% Validation code s postpended to wvfZernikeNMToOSAIndex
%
% 7/29/12 dhb  Wrote it.

% Get j
j = (n.*(n+2) + m) / 2;
