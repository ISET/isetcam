function output = ComputeGammaPolyR(x,input)
% output = ComputeGammaPolyR(x,input)
%
% Compute gamma table using polynomial function.
% Relies on Matlab's built-in polyeval.  No normalization
% or non-negativity constraint.
%
% 10/20/93 dhb      Created from ComputeGammaPoly

% Compute output on full range, make it monotonic.
xP = [x ; 0];
output = polyval(xP',input);

