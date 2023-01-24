function [loc] = centroid(x)
% [loc] = centroid(x)  Finds centroid of vector.
%  Returns centroid location of a vector
%   x   = vector
%   loc = centroid in units of array index
% Peter Burns 5 Aug. 2002
% Copyright (c) International Imaging Industry Association

loc = 0;
for n=1:length(x)
 loc = loc+n*x(n);
end;
loc = loc/sum(x);

