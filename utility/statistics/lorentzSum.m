function val = lorentzSum(params, x)
% Compute sum of Lorentzian components
%
% Syntax:
%	val = lorentzSum(params, x)
%
% Description:
%    This function computes sum of output of multiple lorentzian components
%
%    Value of Lorentzian component can be computed using the constants S,
%    f, and n as, 
%       y = S / (1 + (x / f) ^ 2) ^ n
%
%  Inputs:
%    params - A n-by-3 parameter matrix, with each row containing S, f, and
%             n values for one Lorentzian component.
%    x      - The positions to be evaluated
%
%  Outputs:
%    val    - The sum of output of Lorentzian components, same size as x
%
% Optional key/value pairs:
%    None.
%

% History:
%    xx/xx/14  HJ   ISETBIO TEAM, 2014
%    12/14/17  jnm  Formatting
%    01/19/18  jnm  Formatting update to match Wiki.

%% Check inputs
if ~exist('params', 'var'), error('parameters required'); end
if isvector(params), params = params(:)'; end
if size(params, 2) ~= 3, error('parameter matrix size error'); end
if ~exist('x', 'var'), error('evaluation point x required'); end

%% Accumulate values from each component
%  Init val to zero
val = zeros(size(x));

%  Make sure params are non-negative
params = abs(params);

%  Loop and compute val for each component
for ii = 1 : size(params, 1)
    val = val + params(ii, 1) ...
        ./ (1 + (x / params(ii, 2)) .^ 2) .^ params(ii, 3);
end

end