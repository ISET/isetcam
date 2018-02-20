function [spd_out] = SplineSpd(wls_in, spd_in, wls_out, extend)
% [spd_out] = SplineSpd(wls_in, spd_in, wls_out, [extend])
%
% Convert the wavelength representation of a spectral power distribution.
% Takes change of deltaLambda into account to keep matrix computations
% consistent across wavelength samplings.
%
%
% Handling of out of range values:
%   extend == 0: Cubic spline, extends with zeros [default]
%   extend == 1: Cubic spline, extends with last value in that direction
%   extend == 2: Linear interpolation, linear extrapolation
%
% spd_in may have multiple columns, in which case srf_out does as well.
%
% wls_in and wls_out may be specified as a column vector of
% wavelengths or as a [start delta n] description.
%
% 5/6/98  dhb  Change normalization method so that sum is constant.
%              This is a little closer to the desired result for
%              functions with big derivatives.
% 12/7/98 dhb  Remove 5/6/98 change, as it produces the wrong power
%              when you spline across different wavelength regions.
% 7/26/03 dhb  Add extend argument and pass to SplineRaw.
% 8/13/11 dhb  Update comment to reflect changes in SplineRaw.

if (nargin < 4)
	extend = [];
end
spd_raw = SplineRaw(wls_in,spd_in,wls_out,extend);

% Now take change in deltaLambda into account in power measure
S_in = MakeItS(wls_in);
S_out= MakeItS(wls_out);
convertPower = S_out(2)/S_in(2);
spd_out = convertPower*spd_raw;
