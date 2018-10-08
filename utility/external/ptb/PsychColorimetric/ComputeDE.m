function DE = ComputeDE(input1,input2)
% DE = ComputeDE(input1,input2)
%
% Compute the vector length between each of the
% columns of two matrices.
%
% Useful in color difference calculations.
%
% 10/17/93    dhb  Wrote it.
% 12/18/98    dhb  Re-wrote so as not to be a memory hog.

DE = sqrt(sum((input1-input2).^2,1));

