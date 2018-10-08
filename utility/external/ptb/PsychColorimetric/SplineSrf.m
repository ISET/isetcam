function [srf_out] = SplineSrf(wls_in, srf_in, wls_out, extend)
% [srf_out] = SplineSrf(wls_in, srf_in, wls_out, [extend])
%
% Convert the wavelength representation of a surface reflectance function.
%
%
% Handling of out of range values:
%   extend == 0: Cubic spline, extends with zeros [default]
%   extend == 1: Cubic spline, extends with last value in that direction
%   extend == 2: Linear interpolation, linear extrapolation
%
% srf_in may have multiple columns, in which case srf_out does as well.
%
% wls_in and wls_out may be specified as a column vector of
% wavelengths or as a [start delta num] description.
%
% 7/26/03 dhb  Add extend argument and pass to SplineRaw.
% 8/13/11 dhb  Update comment to reflect changes in SplineRaw.

if (nargin < 4)
	extend = [];
end
srf_out = SplineRaw(wls_in,srf_in,wls_out,extend);
