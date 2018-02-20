function [srf_out] = SplineSrf(wls_in, srf_in, wls_out, extend)
% [srf_out] = SplineSrf(wls_in, srf_in, wls_out, [extend])
%
% Convert the wavelength representation of a surface
% reflectance function by using a cubic spline.
%
% Truncates to zero outside the range of the input spectrum, unless
% extend == 1.  In this case, it extends in each direction with the
% last available value.
%
% srf_in may have multiple columns, in
% which case srf_out does as well.
%
% wls_in and wls_out may be specified as a column vector of
% wavelengths or as a [start delta num] description.
%
% 7/26/03 dhb  Add extend argument and pass to SplineRaw.

if (nargin < 4)
	extend = [];
end
srf_out = SplineRaw(wls_in,srf_in,wls_out,extend);
