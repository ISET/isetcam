function output = ComputeGammaPoly(x,input)
% output = ComputeGammaPoly(x,input)
%
% Compute gamma table using polynomial function.
% Relies on Matlab's built-in polyeval.
%
% Assumes that 1 is maximum input value
%
% 10/3/93  dhb,jms  Normalize output to max of 1.
%                   Better be sure that last value is max setting.
% 10/4/93  dhb      Force monotonicity
% 6/5/10   dhb      Update for [0,1] input convention.

% Check input condition
if (max(input) ~= 1)
    error('ComputeGammaPoly assumes that maximum of input values will be unity.');
end

% Compute output on full range, make it monotonic.
xP = [x ; 0];
output = MakeMonotonic(HalfRect(polyval(xP',input)));
if (max(output) ~= 0)
  output = NormalizeGamma(output);
end
