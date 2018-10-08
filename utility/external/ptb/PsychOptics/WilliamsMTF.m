function mtf = WilliamsMTF(s)
%WILLIAMSMTF  Compute the MTF measured by Williams et. al.
%   mtf = WILLIAMSMTF(s)
% 
%   Compute the MTF measured by Williams et. al. for 633 nm light,
%   representing the optical quality of human foveal vision.  The empirical
%   MTFs were obtained for a 3 mm pupil.
%
%   Williams, D.R. Brainard, D.H., McMahon, M., and Navarro, R. (1994).
%   Double pass and interferometric measures of the optical quality of the
%   human eye. Journal of the Optical Society of America A, 11, 3123-3135.
%   Formulae given in Equation 1 ff.
%
%   Spatial frequency passed in cycles/deg.
%
%   See also OTFTOPSF, WILLIAMSRESTMTF, DIFFRACTIONMTF,
%   WILLIAMSTABULATEDPSF, PSYCHOPTICSTEST.

% 7/11/94		dhb		Wrote it.
% 7/14/94		dhb		Pulled calculation of rest into separate function.

diff = DiffractionMTF(s,3,633);
rest = WilliamsRestMTF(s);
mtf = diff .* rest;
