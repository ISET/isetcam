function output = Cross3D(v1,v2,v3)
% output = Cross3D(v1,v2,v3)
% 
% Produce a matrix of 3D column vectors that cross all
% combinations of the passed input vectors.
%
% See also meshgrid, ndgrid.
%
% 8/25/97   dhb  Add to Cal subfolder.

output = zeros(3,length(v1)*length(v2)*length(v3));
index = 1;
for i = 1:length(v1)
  for j = 1:length(v2)
    for k = 1:length(v3)
      output(1,index) = v1(i);
      output(2,index) = v2(j);
      output(3,index) = v3(k);
      index = index+1;
    end
  end
end
