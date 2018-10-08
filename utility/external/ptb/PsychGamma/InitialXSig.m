function x = InitialXSig(xp)
% x = InitialXSig(xp)
%
% Initial values for sigmoid function fit.
%
% If argument is passed, it is assumed to be 
% a best guess from some source for the first
% two arguments.  Roughly these should be the
% input value for half maximum output and the
% value of maximum output.

x = [1 1 1]';
if (nargin == 1)
  x(1) = xp;
end

