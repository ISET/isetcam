function w = humanAchromaticOTF(sampleSF)
% OTF fall off at optimal wavelength (no chromatic aberration)
%
%  sampleSF:  Spatial frequency vector (cyc/deg)
%
% Example:
%   sampleSF = 0:60;
%   w = humanAchromaticOTF(sampleSF);
%   plot(sampleSF,w)
%
% Copyright ImagEval Consultants, LLC, 2011.

% NOTE:
% This is a typical human OTF scaling we use from the work at Dave
% Williams' lab.  Here is a smooth fit to their data.  This was provided by
% Dave Brainard and could be updated or drawn from the literature in some
% other way.  Perhaps from Ijspeert?
%

if ieNotDefined('sampleSF'), sampleSF = 0:50; end

a = 0.1212; %Parameters of the fit
w1 = 0.3481; %Exponential term weights
w2 = 0.6519;
w = w1 * ones(size(sampleSF)) + w2 * exp(-a*sampleSF);

return
