function gauss = gauss(hwhm, support)
% Gaussian vector with halfwidth half max and support specified
%
%  g = gauss(hwhm, support)
%
% The hwhm must be greater than one.
%
% The hwhm specifies the support of the gaussian between the points
% where it obtains half of its maximum value.  The support indicates the
% gaussians support in pixels.
%
% The univariate Gaussian is
%
%    g1 = (1/s sqrt(2pi)) exp(-(x/2s)^2)
%
% The univariate hwhm, h, is the value where the Gaussian is at half
% of its maximum value.
%
% The support indicates the gaussians spatial support in pixels. The
% hwhm must be greater than one.
%
% The relationship between the standard deviation, s, and the half max is
%
%     s  = h / (2*sqrt(ln(2))),  for 1D Gaussian and
%

if (nargin < 2), error('Two input arguments required'); end

    x = (1:support) - round(support/2);

    s = ieHwhm2SD(hwhm, 1);
    gauss = exp(-(x / (2 .* s)).^2);

    gauss = gauss / sum(sum(gauss));

    return;