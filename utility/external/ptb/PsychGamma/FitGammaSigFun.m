function [err,con] = FitGammaSigFun(x,values,measurements)
% [err,con] = FitGammaSigFun(x,values,measurements)
% 
% Error function for sigmoid function fit.

predict = ComputeGammaSig(x,values);
err = ComputeFSSE(measurements,predict);
con = [-x(1) -x(2) -x(3)];
