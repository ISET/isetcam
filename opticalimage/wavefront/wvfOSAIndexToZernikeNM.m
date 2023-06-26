function [n, m] = wvfOSAIndexToZernikeNM(j)
% Convert OSA single Zernike index to the Zernike 2-index standard indexing
%
% Syntax:
%   [n,m] = wvfOSAIndexToZernikeNM(j)
%
% Description:
%    Convert the OSA single Zernike index (starting at j = 0) to the
%    Zernike 2-index standard indexing.
%
%    Uses equations 5 and 6 from the OSA numbering document
%
% Inputs:
%    n - The radial order
%    m - The angular frequency
%
% Outputs: 
%    j - Can be a vector, in which case so are m and n.
%
% Optional key/value pairs:
%    None.
%
% See Also:
%    wvfOSAIndexToVectorIndex, wvfOSAIndexToZernikeNM, zernfun
%

% History:
%    xx/xx/13  DHB  (c) Wavefront Toolbox Team, 2013
%    11/09/17  jnm  Formatting
%    01/11/18  jnm  Formatting update to match Wiki

% Examples:
%{
    wvfOSAIndexToZernikeNM(15)
%}
%{
    j = 1:100;
    [n, m] = wvfOSAIndexToZernikeNM(j);
    jCheck = wvfZernikeNMToOSAIndex(n, m);
    if (any(jCheck ~= j))
        error('Zernike index conversion routines do not invert properly');
    end
%}

% Radial order n
n = ceil((-3 + sqrt(9 + 8 * j)) / 2 );
m = 2 * j - n .* (n + 2);

return


