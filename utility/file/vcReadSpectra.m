function [res,wave,comment] = vcReadSpectra(fname,wave,extrapVal)
% Deprecated.  Use
%
%   [res,wave,comment,partialName] = ieReadSpectra(fname,wave,extrapVal)
%
% Read in spectral data and interpolate to the specified wavelengths
%
% These are the previous comments.  This file was simply copied to
% ieReadSpectral to preserve function naming conventions.  No functionality
% was changed.
%
% If you are reading a color filter, you should probably use
% ieReadColorFilter rather than this routine
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('extrapVal')
    [res,wave,comment] = ieReadSpectra(fname,wave);
else
    [res,wave,comment] = ieReadSpectra(fname,wave,extrapVal);
end

end


