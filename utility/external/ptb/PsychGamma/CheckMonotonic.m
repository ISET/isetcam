function bool = CheckMonotonic(vector)
% bool = CheckMonotonic(vector)
%
% Check whether the passed vector is monotonically non-decreasing.
% 
% Return 1 if so, 0 if not.

[m,n] = size(vector);
diff = vector(1:m-1) - vector(2:m);
index = find(diff > 0);
if (~isempty(index))
  bool = 0;
else
  bool = 1;
end

