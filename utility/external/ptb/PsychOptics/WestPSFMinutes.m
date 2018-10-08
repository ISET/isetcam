function psf = WestPSFMinutes(radius)
%WESTPSFMINUTES  Compute Westheimer estimate of human PSF
%   psf = WestPSFMinutes(radius)
%
%   Compute Westheimer's PSF function as a function
%   of passed radius.  Radius passed in minutes of arc.
%
%   Formula from Westheimer G. 1986. The eye as an optical instrument.  In
%   Handbook of perception and human performance, KR Boff, L Kaufman,
%   JP Thomas (eds). New York: Wiley.  Equation 7.
%
%   This is only approximately consistent with Westheimer's LSF estimate.
%
%   This comes back normalized to a maximum of 1.
%
%   See also WestLSFMinutes, DavilaGeislerPSFMinutes, LsfToPsf, PsfToLsf

% 7/11/94		dhb		Added comments, changed name.

psf = 0.952*exp(-2.59*(radius.^1.36)) + ...
       0.048*exp(-2.43*(radius.^1.74));
