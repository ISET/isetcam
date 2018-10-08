function output = HalfRect(input)
% output = HalfRect(input)
% 
% Rectify column vector input at zero and value of its last entry.
%
% 3/15/94		dhb, jms		Modified to truncate at last value, too.

output = real(input);
[m,n] = size(input);
if (n > 1)
	error('cannot handle more than 1 column');
end
normVal = input(m,1);
index = find(input < 0);
if (~isempty(index))
  output(index) = zeros(length(index),1);
end
index = find(input > normVal);
if (~isempty(index))
	output(index) = normVal*ones(length(index),1);
end

