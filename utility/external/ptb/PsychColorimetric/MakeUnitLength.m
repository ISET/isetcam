function output = MakeUnitLength(input)
% output = MakeUnitLength(input)
%
% Make each column of the input have unit length.
% 
% 8/3/96  dhb  Added this comment.

[m,n] = size(input);
output = zeros(m,n);
for i = 1:n
  output(:,i) = input(:,i) / norm(input(:,i));
end
