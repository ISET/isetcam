function result = visualAngle(numpixels, viewdist, dpi, va)
%
%       result = visualAngle(numpixels, viewdist, dpi, va)
%
% Author:  Xuemei Zhang  12/8/95
% Purpose:
%   Utility to compute visual angle (or numpixels, viewdist, dpi) of a
%   display monitor.
%
%   The parameter to be computed variable's value should be set to -1.
%   The value will be computed from the other variables and returned as the
%   result.
%
%   If va (viewing angle) is not given, it is taken as the unknown.
%
% Examples:
% visualAngle(20, 12, 72)
%   returns the visual angle spanned by 20 pixels on a 72dpi display at 12
%   inch viewing distance;
% visualAngle(-1, 12, 72, 5)
%   returns the number of pixels needed to span 5 degrees visual angle on a
%   72dpi display at 12 inch viewing distance.
%
% Viewdist: inches.
% Va:       degrees (of angle).
% Dpi:      dots-per-inch [default = 90]
%

disp('visualAngle:  Obsolete');
evalin('caller', 'mfilename');

% Should be updated to ieNotDefined status.
if (nargin < 4), va = -1; end
if (nargin < 3), dpi = 90; end

% Check to make sure there is only one unknown
pixOK = (numpixels < 0 & length(numpixels) == 1);
distOK = (viewdist < 0 & length(viewdist) == 1);
dpiOK = (dpi < 0 & length(dpi) == 1);
vaOK = (va < 0 & length(va) == 1);

check = sum([pixOK, distOK, dpiOK, vaOK]);
if (check ~= 1)
    error('You must choose just one unknown (i.e., only one argument can be -1).');
end

% Let s be the size of the image in inches
if (vaOK || distOK)
    s = numpixels / dpi;
    if (vaOK), result = atan(s/viewdist) * 180 / pi;
    else result = s / tan(va*pi/180);
    end
else
    s = viewdist * tan(va*pi/180);
    if (pixOK), result = dpi * s;
    else result = numpixels / s;
    end
end

return;