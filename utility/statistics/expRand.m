function val = expRand(mn, S)
% Exponentially distributed random number generator
%
% Syntax:
%   val = expRand(mn, S)
%
% Description:
%    An exponentially distributed random number generator. 
%
%    It computes the formula
%         val = -mn .* log(rand(S))
%    This generates a random variable with 
%         1 / mn * exp(-x / mn) as probability density.
%
% Inputs:
%    mn  - (Optional) The distribution mean. Default is 1.
%    s   - (Optional) The size of the returned matrix. Default is 1.
%
% Outputs:
%    val - The returning matrix
%
% Optional key/value pairs:
%    None.
%

% History:
%    xx/xx/10       (c) 2010 Stanford Synapse Team 
%    12/13/17  jnm  Formatting
%    01/19/18  jnm  Formatting update to match Wiki.

% Examples:
%{
	S = [100, 100];
	mn = 3;
	val = expRand(mn,S);
    hist(val(:), 50);
    mean(val(:))
%}

%% Check input
if notDefined('mn'), mn = 1; end
if notDefined('S'), S = 1; end

val = -mn .* log(rand(S));

end