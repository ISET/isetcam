function output = ComputeGammaSig(x,input)
% output = ComputeGammaSig(x,input)
%
% Compute the gamma table using sigmoidal function.
%
% sinput = (input/x(3)).^x(4);
% output = x(2).*sinput./(sinput + x(1));
%
% 10/3/93  dhb,jms  Normalize output to max of 1.
%                   Better be sure that last value is max setting.

if (x(2) <= 0)
  %disp('Illegal value for x(2)');
  x(2) = 0.1;
end
if (x(3) <= 0) 
  %disp('Illegal value for x(3)');
  x(3) = 0.1;
end
sinput = (input/x(2)).^x(3);
output = sinput./(sinput + x(1));
output = NormalizeGamma(output);
