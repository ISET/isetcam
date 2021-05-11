function combinedOtf = makeCombinedOtf(otf, sampleSf)
%
% If you have already created otf, but not combinedOtf,
% then start here.  The data in combinedOtf factors in the other
% optical aberrations of the eye.  We use the interferometric measurements
% from Williams and Brainard to estimate the effect of these other
% aberrations on the human eye.
%
% This is a piece taken from Brian's figures.m code which created the figures
% for the chromatic aberration paper

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	Calculation of combined OTF using Williams et al. formula
%	instead of the old stray light one.  In Williams et al.
%	They predict the MTF at the infocus wavelength by multiplying times
%	a weighted exponential.  We calculate that exponential
%	here and multiply it times the MTF at every wavelength.
%

a = 0.1212; %Parameters of the fit
w1 = 0.3481; %Exponential term weights
w2 = 0.6519;
williamsFactor = w1 * ones(size(sampleSf)) + w2 * exp(-a*sampleSf);
combinedOtf = otf * diag(williamsFactor);
