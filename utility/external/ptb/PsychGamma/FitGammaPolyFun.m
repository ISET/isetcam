function [err,con] = FitGammaPolyFun(x,values,measurements)
% [err,con] = FitGammaPolyFun(x,values,measurements)
% 
% Error function for modified polynomial function fit.

predict = ComputeGammaPoly(x,values);
err = ComputeFSSE(measurements,predict);

con = [-1];
