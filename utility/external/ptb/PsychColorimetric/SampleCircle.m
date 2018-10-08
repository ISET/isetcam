function units = sampleCircle(nTheta,elevation)
% units = sampleCircle(nTheta,elevation)
% 
% Sample points uniformly around a circle.
%
% 8/3/96  dhb  Added this comment.

deltaT = 2*pi/nTheta;
iT = 0;

units = zeros(3,nTheta);
index = 1;
for i = 0:nTheta-1
  theta = iT + i*deltaT;
  units(1,index) = cos(elevation)*cos(theta);
  units(2,index) = sin(elevation)*cos(theta);
  units(3,index) = sin(theta);
  index = index + 1; 
end
