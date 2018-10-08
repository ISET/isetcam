function [err,con] = FitGammaPowFun(x,values,measurements)
% [err,con] = FitGammaPowFun(x,values,measurements)
% 
% Error function for power function fit.

predict = ComputeGammaPow(x,values);
err = ComputeFSSE(measurements,predict);
con = [-x];
