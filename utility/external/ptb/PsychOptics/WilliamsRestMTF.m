function mtf = WilliamsRestMTF(s)
%WILLIAMSRESTMTF  Utility function for WILLIAMSMTF
%   mtf = WILLIAMSRESTMTF(s)
%
%   Compute the portion of the MTF measured by Williams et. al. that is not
%   accounted for by diffraction.
%
%   Williams, D.R. Brainard, D.H., McMahon, M., and Navarro, R. (1994).
%   Double pass and interferometric measures of the optical quality of the
%   human eye. Journal of the Optical Society of America A, 11, 3123-3135.
%   Formulae given in Equation 1 ff.
%
%   Spatial frequency passed in cycles/deg.
%
%   See also WILLIAMSMTF

% 7/14/94		dhb		Wrote it.

a = 0.1212;
w1 = 0.3481;
w2 = 0.6519;
mtf = w1*ones(size(s)) + w2*exp(-a*s);
