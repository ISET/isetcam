function [fit_out,x,err] = FitGammaSpline(values_in,measurements,values_out)
% [fit_out,x,err] = FitGammaSpline(values_in,measurements,values_out)
%
% Cubic spline through gamma data
%
% 7/18/94		dhb		Wrote it.

% Allocate return space
[mOut,nOut] = size(values_out);
fit_out = zeros(mOut,nOut);

% Find first non-zero entry
[mIn,nIn] = size(values_in);
index = find(measurements ~= 0.0);

% Make the data reasonable and interpolate
useMeas = MakeMonotonic(HalfRect(measurements));
fit_out = interp1(values_in,useMeas,values_out,'spline');
x = [];
err = 0;

%[measurements,useMeas,interp1(values_in,useMeas,values_in,'linear')];
