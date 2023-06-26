function j = wvfZernikeNMToOSAIndex(n, m)
% Convert from Zernike 2-index standard index to OSA single-zernike index
%
% Syntax:
%   j = wvfZernikeMNToOSAIndex(n,m)
%
% Description:
%    Convert from the Zernike 2 index standard indexing to the OSA single
%    Zernike index (starting at j = 0)
% 
%    Uses equation 4 from the OSA numbering document
%
% Inputs:
%    n - The radial order
%    m - The angular frequency
%
% Outputs:
%    j - Can be a vector, in which case n and m would also be vectors.
%
% Optional key/value pairs:
%    None.
%
% Notes:
%    * Validation code s postpended to wvfZernikeNMToOSAIndex
%
% See Also:
%    wvfZernikeNMToOSAIndex, zernfun
%

% History:
%    07/29/12  dhb  Wrote it.
%    11/09/17  jnm  Formatted
%    01/11/18  jnm  Formatting update to match Wiki, rename to match
%                   function's filename. (From MNTo... to NMTo...)

% Examples:
%{
    osa_ind = wvfZernikeNMToOSAIndex(0,0)
    osa_ind = wvfZernikeNMToOSAIndex(4,6)
%}
%{
    j = 1:100;
    [n, m] = wvfOSAIndexToZernikeNM(j);
    jCheck = wvfZernikeNMToOSAIndex(n, m);
    if (any(jCheck ~= j))
        error('Zernike index conversion routines do not invert properly');
    end
%}

% Get j
j = (n .* (n + 2) + m) / 2;
