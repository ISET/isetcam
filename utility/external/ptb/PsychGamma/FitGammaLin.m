function [fit_out,x,err] = FitGammaLin(values_in,measurements,values_out)
% [fit_out,x,err] = FitGammaLin(values_in,measurements,values_out)
%
% Linearly interpolate gamma data
%
% 3/15/94		dhb, jms		Wrote it.

% Allocate return space
[mOut,nOut] = size(values_out);
fit_out = zeros(mOut,nOut);

% Find first non-zero entry
[mIn,nIn] = size(values_in);
index = find(measurements ~= 0.0);

% Make the data reasonable and interpolate
useMeas = MakeMonotonic(HalfRect(measurements));
fit_out = interp1(values_in,useMeas,values_out,'linear');
x = [];
err = 0;

%[measurements,useMeas,interp1(values_in,useMeas,values_in,'linear')];
