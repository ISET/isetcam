function output = Cross2D(v1,v2)
% output = Cross2D(v1,v2)
% 
% Produce a matrix of 2D column vectors that cross all
% combinations of the passed input vectors.
%
% See also meshgrid, ndgrid.
%
% 8/25/97   dhb  Add to Cal subfolder.

output = zeros(2,length(v1)*length(v2));
index = 1;
for i = 1:length(v1)
  for j = 1:length(v2)
    output(1,index) = v1(i);
    output(2,index) = v2(j);
    index = index+1;
  end
end
