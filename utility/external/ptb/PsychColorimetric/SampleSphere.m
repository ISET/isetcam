function units = sampleSphere(nTheta,nPhi)
% units = sampleSphere(nTheta,nPhi)
%
% Sample points on a sphere.%
% 
% 8/3/96  dhb  Added this comment.

deltaT = 2*pi/nTheta;
deltaP = pi/nPhi;

iT = 0;
iP = -pi/2;

units = zeros(3,nTheta*nPhi);
index = 1;
for i = 0:nTheta-1
  theta = iT + i*deltaT;
  for j = 0:nPhi-1
    phi = iP + j*deltaP;
    units(1,index) = cos(phi)*cos(theta);
    units(2,index) = cos(phi)*sin(theta);
    units(3,index) = sin(phi);
    index = index + 1; 
  end
end
