function [spec_out] = SplineRaw(wls_in, spec_in, wls_out, extend)
% [spec_out] = SplineRaw(wls_in, spec_in, wls_out, [extend])
%
% Convert the wavelength representation of a spectrum by using a cubic
% spline.
%
% Truncates to zero outside the range of the input spectrum, unless
% extend == 1.  In this case, it extends in each direction with the
% last available value.
%
% spec_in may have multiple columns, in
% which case spec_out does as well.
%
% wls_in and wls_out may be specified as a column vector of
% wavelengths or as a [start delta num] description.
%
% 7/26/03  dhb  Add extend argument

% Default value for extend
if (nargin < 4 | isempty(extend))
	extend = 0;
end

% Convert wls_in wls_out to lists if necessary
wls_in = MakeItWls(wls_in);
wls_out = MakeItWls(wls_out);

% Spline the whole enchilada
[null,n] = size(spec_in);
[m,null] = size(wls_out);
spec_out = zeros(m,n);
for i=1:n
  spec_out(:,i) = spline(wls_in,spec_in(:,i),wls_out);
end

% Find range of input spectrum
min_wl = min(wls_in);
max_wl = max(wls_in);

% Truncate to zero outsize of critical range
if (extend)
	index = find( wls_out < min_wl);
	if (~isempty(index))
		for i=1:n
	  	spec_out(index,i) = spec_in(1,i);
		end
	end
	index = find(wls_out > max_wl);
	if (~isempty(index))
		for i=1:n
	  	spec_out(index,i) = spec_in(end,i);
		end
	end
else
	index = find( wls_out < min_wl | wls_out > max_wl );
	if (length(index) ~= 0)
	  spec_out(index,:) = zeros(length(index),n); 
	end
end




