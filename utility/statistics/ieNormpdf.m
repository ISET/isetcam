function y = ieNormpdf(x, mu, sigma)
% Normal probability density function (pdf).
%
% Syntax:
%   Y = ieNormpdf(X, [mu], [sigma])
%
% Description:
%    Returns the normal pdf with mean, MU, and standard deviation, SIGMA,
%    at the values in X. The resulting size of Y is the common size of the
%    input arguments. A scalar input functions as a constant matrix of the
%    same size as the other inputs.
%
%    Examples are located within the code. To access the examples, type
%    'edit ieNormpdf.m' into the Command Window.
%
% Inputs:
%    x     - The data to analyze
%    mu    - (Optional) The mean. Default value 0.
%    sigma - (Optional) The standard deviation. Default value 1.
%
% Outputs:
%    y     - The normal probability density function. Size of the result
%            will depend on the input arguments size.
%
% Optional key/value pairs:
%    None.
%
% Examples are included within the code.
%
% References:
%    [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%         Functions", Government Printing Office, 1964, 26.1.26.
%

% History:
%    xx/xx/xx  JRG/BW ISETBIO Team
%    12/15/17  jnm    Formatting
%    01/29/18  jnm    Formatting update to match Wiki

% Examples:
%{
    ieNormpdf(0)
    x = linspace(-3, 3, 100);
    mu = zeros(size(x));
    sigma = ones(size(x));
    n = ieNormpdf(x, mu, sigma);
    vcNewGraphWin;
    plot(x, n);
    grid on

    sigma = 0.2 * sigma;
    mu = mu + 2;
    x = x + 2;
    n = ieNormpdf(x, mu, sigma);
    vcNewGraphWin;
    plot(x, n);
    grid on
%}

% By default a standard normal
if nargin < 3, sigma = 1; end
if nargin < 2; mu = 0; end
if nargin < 1, error('Requires at least one input argument.'); end

% Check for size agreement in args.  This won't catch all errors,
% if the number of elements is the same but the dimensions differ.
if (numel(x) ~= numel(mu) | numel(x) ~= numel(sigma) )
    error('Requires arguments to match in size.');
end

% Check that sigma is positive
if ~isempty(find(sigma <= 0, 1)), error('Sigma must be > 0'); end

xn = (x - mu) ./ sigma;
y = exp(-0.5 * xn .^ 2) ./ (sqrt(2 * pi) .* sigma);

end