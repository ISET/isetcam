function [x1 x2 x3] = scGaussianParameters(sampPerDeg,params)
% Define the Gaussian parameters for the Spatial-CIELAB filters
%
%    [x1 x2 x3] = scGaussianParameters(sampPerDeg,params)
%
% Each of the three color channel filters is represented as the weighted
% sum of two or three gaussians.  The code below represents the parameters
% in the format
%
%     [halfwidth weight halfwidth weight ...]
%
% There are several versions of the parameters that you can use.
% At the moment these are: 'original', 'distribution', 'hires'
%
% The original parameters defined in Zhang and Wandell (1996), Table on
% page 3, were defined as a weight and as a spread in the formula
%
%    w exp(- (x^2 + y^2) / s^2)
%
% This matrix contains [h w h w ] pairs (3 for the first) where
%  h is the halfwidth-half-max of the Gaussian
%  w is the weight
%
% x1 = [0.0283    0.921    0.133    0.105    4.336   -0.1080];
% x2 = [0.0392    0.531    0.494    0.33];
% x3 = [0.0536    0.488    0.386    0.371];
%
% Johnson and Fairchild have a nice review and re-publish these weights in
% a way that matches the distribution, rather than the original paper.  In
% their table and distribution the weights sum to 1.
%
%    w = x1(2:2:end); w = w/sum(w(:))
%
%
% x1 = [0.05     1.00327    0.225    0.11442   7.0   -0.11769];
% x2 = [0.0685    0.5310    0.826    0.33];
% x3 = [0.0920    0.4877    0.6451    0.371];
%
% Also, the spreads match the distribution - not the published paper.
%
% This routine contains a third set of 'hires' parameters as well, which is
% the same as the original but the spreads are divided by 2.
%
% When reading this and related code, you will notice that we use the
% Gaussian functions, rather than the simple formula above.  I am not sure
% when that happened. Hence, when computing the filters we must transform
% the half-width half-max to a standard deviation.  There is a routine,
% ieHwhm2SD that does this.  The formula for the bivariate Gaussian is:
%
%   exp(-(1/2)(x/sx)^2 + (y/sy)^2) = exp(-(1/2)(x/sx)^2) * exp(-(1/2) (y/sy)^2)
%
% It is possible that the differences in the spread (which is very blurry
% for all channels, even the luminance) came about because in the early
% days there was some confusion about the SD, HWHM, and the various
% formulae.
%
% Example:
%  If we have twice as many samples per degree, we have twice the
%  halfwidth. So, in the first case the halfwidths are double the second
%  case.  The relative weights stay the same.
%
%   [x1 x2 x3] = scGaussianParameters(200);
%   [y1 y2 y3] = scGaussianParameters(100);
%   y2./x2 , y3 ./ x3
%
% See also:  scPrepareFilters, s_scAnalysis, ieHwhm2SD
%
% Copyright ImagEval Consultants, LLC, 2007.

if ieNotDefined('params'), v = 'distribution'; end
if   ~checkfields(params,'filterversion'), v = 'distribution';
else  v = params.filterversion;
end

switch v
    case {'distribution','johnson'}
        
        % These are the same filter parameters in Z-W distribution and
        % printed in Johnson-Fairchild.  The weights (and apparently the
        % spreads) differ from the paper. Normalizing the weights
        % eliminates the need to normalize the Gaussians after summing the
        % filters.  I don't understand why the spreads are broader.
        x1 = [0.05     1.00327     0.225    0.114416   7.0  -0.117686];
        x2 = [0.0685   0.616725    0.826    0.383275];
        x3 = [0.0920   0.567885    0.6451   0.432115];
        
    case {'original','published1996'}
        % From the original publication by Zhang and Wandell.  Notice that
        % these spreads are approximately half the size of the spreads
        % above. So, if the ones above are 2s (like the Gaussian) these are
        % s, like the publication.  But the publication doesn't have the
        % 2s, only the s.  Very confusing.
        x1 = [0.0283    0.921    0.133    0.105    4.336   -0.1080];
        x2 = [0.0392    0.531    0.494    0.33];
        x3 = [0.0536    0.488    0.386    0.371];
        
    case {'hires'}
        % Double the resolution
        x1 = [0.0283/2    0.921    0.133/2    0.105    4.336/2   -0.1080];
        x2 = [0.0392/2    0.531    0.494/2    0.33];
        x3 = [0.0536/2    0.488    0.386/2    0.371];
        
    otherwise
        error('Unknown version %s\n',v);
end

% I am not sure this should be done here. (BW)
% Convert the visual angle, how they are specified, into samples.  This
% uses information about the number of samples per degree.
x1([1 3 5]) = x1([1 3 5]) * sampPerDeg;     % Three Gaussians
x2([1 3])   = x2([1 3])   * sampPerDeg;     % Two Gaussians
x3([1 3])   = x3([1 3])   * sampPerDeg;

return;