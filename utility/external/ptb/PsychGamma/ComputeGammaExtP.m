function output = ComputeGammaExpP(x,input)
% output = ComputeGammaExpP(x,input)
%
% Compute the gamma table using an extended power function.
% See Brainard, Pelli, & Robson (2001).
%
% Largest value in input must be the maximum device
% setting.  This is wise during measurements in 
% any case.
%
% 9/21/93  dhb,ccc  Added checks for parameter bounds.
% 10/3/93  dhb,jms  Normalize output to max of 1.
%                   Better be sure that last value is max setting.
% 8/7/00   dhb      Rewrote equation this uses completely.

thePow = x(1);
theOffset = x(2);

maxInput = max(input);
minPow = 1e-5;
if (thePow < minPow)
  thePow = minPow;
end
if (theOffset < 0)
	theOffset = 0;
end
if (theOffset > maxInput)
	theOffset = maxInput;
end

output = zeros(size(input));
index = find(input > theOffset);
if (~isempty(index))
	output(index) = ((input(index)-theOffset)/(maxInput-theOffset)).^thePow;
end


