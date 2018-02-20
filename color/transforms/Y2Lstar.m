function Lstar = Y2Lstar(Y,Yn)
% Convert Y (luminance) to L* (CIELAB)
%
%  Lstar = Y2Lstar(Y,Yn)
%
% Purpose:
%   Convert luminance (1931 CIE Y coordinate) into CIELAB/CIELUV L* The
%   luminance of the white point (Yn) is required.
%
% References
%   Wyszecki and Stiles, others.
%
% Copyright ImagEval Consultants, LLC, 2003.

% Basic formula
T = Y/Yn;
Lstar = 116*(T.^(1/3)) - 16;

% Buf if the ratio is small ...
l = (T < .008856);
Lstar(l) = 903.3*T(l);

return;