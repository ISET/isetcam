function y = iePrctile(x, p)
% Measures the percentiles of the sample in X.
%
% Syntax:
%   y = prctile(x, p)
%
% Description:
%    Returns the value in the vector X that is greater than P percent
%    of the values in X. For example, prctile(x, 50) is the median of X. 
%
%    P may be either a scalar or a vector. For scalar P, Y is a row   
%    vector containing Pth percentile of each column of X. For vector P, 
%    the ith row of Y is the P(i) percentile of each column of X.
%
%    *Modified from the Matlab distribution.*
%
% Inputs:
%    x - The vector to pull value(s) from
%    p - The percentile(s) (scalar or vector) to pull from x
%
% Outputs:
%    y - The value(s) matching the provided percentile(s). See description
%        for additional clarification.
%
% Optional key/value pairs:
%    None.
%

if checkToolbox('Statistics Toolbox')
    % Matlab toolbox version is present. Use it.
    y = prctile(x, p);
    return
end

[prows, pcols] = size(p);
if prows ~= 1 && pcols ~= 1, error('P must be a scalar or a vector.'); end

if any(p > 100) || any(p < 0)
    error('P must take values between 0 and 100');
end

xx = sort(x);
[m, n] = size(x);

if m == 1 || n == 1
    m = max(m, n);
	if m == 1
	   y = x * ones(length(p), 1);
	   return;
	end
    % n = 1;
    q = 100 * (0.5:m - 0.5) ./ m;
    xx = [min(x); xx(:); max(x)];
else
    q = 100 * (0.5:m - 0.5) ./ m;
    xx = [min(x); xx; max(x)];
end

q = [0 q 100];
y = interp1(q, xx, p);

end
