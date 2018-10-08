function [spd_out] = SplineSpd(wls_in, spd_in, wls_out, extend)
% [spd_out] = SplineSpd(wls_in, spd_in, wls_out, [extend])
%
% Convert the wavelength representation of a spectral power distribution.
% Takes change of deltaLambda into account to keep matrix computations
% consistent across wavelength samplings.
%
% Handling of out of range values:
%   extend == 0: Cubic spline, extends with zeros [default]
%   extend == 1: Cubic spline, extends with last value in that direction
%   extend == 2: Linear interpolation, linear extrapolation
%
% spd_in may have multiple columns, in which case spd_out does as well.
%
% wls_in and wls_out may be specified as a column vector of
% wavelengths or as a [start delta n] description.
%
% If wls_out is passed as a vector of wavelengths with just one sample, we don't 
% know what the wavelength sampling is, and we can't do the conversion of
% power per wavelength band.  This condition is checked for and an error is
% thrown.  The fix is to pass the wavelengths as an S vector
%   S = [theWavelength wavelengthBandWidth 1].
% This forces an explicit value for the wavelength band width.
%
% 5/6/98  dhb  Change normalization method so that sum is constant.
%              This is a little closer to the desired result for
%              functions with big derivatives.
% 12/7/98 dhb  Remove 5/6/98 change, as it produces the wrong power
%              when you spline across different wavelength regions.
% 7/26/03 dhb  Add extend argument and pass to SplineRaw.
% 8/13/11 dhb  Update comment to reflect changes in SplineRaw.
% 5/10/12 dhb  Small comment fix
% 1/15/18 dhb  Can't believe I wrote this more than 20 years ago!
%         dhb  Put in error check for single wavelength value pass.

if (nargin < 4)
	extend = [];
end
spd_raw = SplineRaw(wls_in,spd_in,wls_out,extend);

% Now take change in deltaLambda into account in power measure
if (length(wls_in(:)) == 1)
    fprintf('Cannot determine delta lambda when only a single input wavelength is specified.\n');
    fprintf('Call with S = [theWavelength wavelengthBandWidth 1] rather than just by\n');
    fprintf('passing a single wavelength, where wavelengthBandWidth is the width of\n');
    fprintf('the wavelength band for which power is specified.\n\n');
    error('Change single passed input wavelength to S format');
end
S_in = MakeItS(wls_in);

if (length(wls_out(:)) == 1)
    fprintf('Cannot determine delta lambda when only a single output wavelength is specified.\n');
    fprintf('Call with S = [theWavelength wavelengthBandWidth 1] rather than just by\n');
    fprintf('passing a single wavelength, where wavelengthBandWidth is the width of\n');
    fprintf('the wavelength band for which power is specified.\n\n');
    error('Change single passed output wavelength to S format');
end
S_out= MakeItS(wls_out);

convertPower = S_out(2)/S_in(2);
spd_out = convertPower*spd_raw;
