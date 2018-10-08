function input = InvertGammaExpP(x,maxInput,output)
% output = InvertGammaExpP(x,input)
%
% Invert the gamma table using an extended power function.
% See Brainard, Pelli, & Robson (2001).
%
% Parameter x are the function parameters as returned
% by FitGamma/FitGammaExtP.  See ComputeGammaExtP.
%
% Parameter maxInput is the maximum device input
% value (typically 1).
%
% 8/7/00   dhb      Wrote it.
% 6/5/10   dhb      Update for OS/X assumption of input values as real's in [0-1]

thePow = x(1);
theOffset = x(2);

input = ((maxInput-theOffset)*(output.^(1/thePow))) + theOffset;

