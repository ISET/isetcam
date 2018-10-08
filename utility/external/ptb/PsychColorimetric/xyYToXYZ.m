function XYZ = xyYToXYZ(xyY)
% XYZ = xyYToXYZ(xyY)
%
% Compute tristimulus coordinates from
% chromaticity and luminance.
%
% 8/24/09  dhb  Look at it.

[m,n] = size(xyY);
XYZ = zeros(m,n);
for i = 1:n
  z = 1 - xyY(1,i) - xyY(2,i);
  XYZ(1,i) = xyY(3,i)*xyY(1,i)/xyY(2,i);
  XYZ(2,i) = xyY(3,i);
  XYZ(3,i) = xyY(3,i)*z/xyY(2,i);
end
