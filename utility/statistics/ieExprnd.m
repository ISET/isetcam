function r = ieExprnd(mu, varargin)
% Random arrays from exponential distribution.
%
% Syntax:
%	R = ieExprnd(mu, [varargin])
%
% Description:
%    The function returns an array of random numbers chosen from within the
%    exponential distribution with a location parameter mu. The size of R
%    is the size of MU.
%
% Inputs:
%	 mu       - The location parameter
%    varargin - an array containing the dimensionality of R. Ex.
%               R = EXPRND(MU, [M, N, ...]) returns an M-by-N-by-... array.
%
% Outputs:
%    r        - The resulting random arrays with dimensionality determined
%               by the input variable(s) in varargin.
%
%   References:
%	 [1] Devroye, L. (1986) Non-Uniform Random Variate Generation, 
%        Springer-Verlag.
%    * Modified from Fred Rieke's version of the Mathworks code. Found at:
%      http://rieke-server.physiol.washington.edu/People/Fred/Classes/ ...
%           545/matlab/StochasticProcessesTutorial/exprnd.m
%

% Examples:
%{
    r = ieExprnd(10, 1, 5000);
    vcNewGraphWin;
    hist(r, 50);
%}

if nargin < 1
    error('stats:exprnd:TooFewInputs Requires 1+ input arguments.');
end

% [err, sizeOut] = statsizechk(1, mu, varargin{:});
% if err > 0
%     error('stats:exprnd:InputSizeMismatch', ...
%       'Size information is inconsistent.');
% end

% Return NaN for elements corresponding to illegal parameter values.
if mu < 0, error('Exponential parameter less than zero.'); end
% mu(mu < 0) = NaN;

sz = zeros(1, length(varargin));
for ii = 1:length(varargin), sz(ii) = varargin{ii}; end

% r = zeros(sz);
% Generate uniform random values, and apply the exponential inverse CDF.
r = -mu .* log(rand(sz)); % == expinv(u, mu)

end
