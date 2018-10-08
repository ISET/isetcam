function [err,con] = FitGammaExtPFun(x,values,measurements)
% [err,con] = FitGammaExtPFun(x,values,measurements)
% 
% Error function for power function fit.
%
% 9/21/93  dhb  Added positivity constraint.
% 8/12/15  dhb  Fix typo, ComputeFSWSE -> ComputeFFSE.

predict = ComputeGammaExtP(x,values);
err = ComputeFSSE(measurements,predict);
con = [-x];
