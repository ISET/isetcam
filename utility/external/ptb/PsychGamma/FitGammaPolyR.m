function [fit_out,x,err] = FitGammaPolyR(values_in,measurements,values_out)
% [fit_out,x,err] = FitGammaPolyR(values_in,measurements,values_out)
%
% Fit homogeneous polynomial to gamma data.
% No forced normalization or non-negativity
%
% 10/20/93    dhb   Wrote it.
% 11/9/93     dhb   Modified to force initial zero entries to be fit with zero.

% Allocate return space
[mOut,nOut] = size(values_out);
fit_out = zeros(mOut,nOut);

% Find first non-zero entry
[mIn,nIn] = size(values_in);
index = find(measurements ~= 0.0);
if (~isempty(index))
  useIndex = index(1);
  useIn = values_in(useIndex:mIn,1);
  useMeas = measurements(useIndex:mIn,1);

  % Get initial values
  x0 = InitialXPolyR(useIn,useMeas);
  x = x0;

  % Compute fit values and error to data for return
  zeroThresh = values_in(useIndex);
  fitOutIndex = find(values_out >= zeroThresh);
  fitInIndex = find(values_in >= zeroThresh);  
  fit_out(fitOutIndex) = ComputeGammaPolyR(x,values_out(fitOutIndex));
  fit_in = ComputeGammaPolyR(x,values_in(fitInIndex));
  err = ComputeFSSE(fit_in,measurements(fitInIndex));
else
  x = [];
  err = 0.0;
end


