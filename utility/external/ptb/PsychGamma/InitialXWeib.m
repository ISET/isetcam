function x = InitialXWeib(values,measurements);

[m,n] = size(measurements);
x = zeros(2,1);
index = find(measurements > measurements(m)/2);
if (~isempty(index))
   x(1) = values(index(1))/.69;
else
   x(1) = values(m)/.69;
end
x(2) = 1;
