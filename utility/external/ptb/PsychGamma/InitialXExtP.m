function x = InitialXExtP(xp)
% x = InitialXExtP(xp)
%
% Initial values for extended power function fit.
%
% If argument is passed, it is assumed to be the
% parameters for best ordinary power function fit.
%
% 8/7/00   dhb  Modify for new equation.
% 11/16/06 dhb  Order of vector was reversed relative to how it's used in
%               FitGammaExpP.  Make default guess for gamma 2.
% 11/16/06 dhb  Adjust initial offset for [0,1] world.

x = [2 0]';
if (nargin == 1)
  x(1) = xp;
end

