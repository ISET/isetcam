function output = ComputeGammaWeib(x,input)
% output = ComputeGammaWeib(x,input)
%
% Compute gamma table using Weibull function.
%
% 10/3/93  dhb  Created from code written by jms.
% 10/3/93  dhb,jms  Normalize output to max of 1.
%                   Better be sure that last value is max setting.

alpha = x(1);
beta = x(2);

z = (input./ alpha) .^ beta;
output = ( 1.0 - exp( - z ) );
output = NormalizeGamma(output);


