function [xyY] = XYZToxyY(XYZ)
% [xyY] = XYZToxyY(XYZ)
%
% Compute chromaticity and luminance from
% from tristimulus values.
%
% 8/24/09  dhb  Speed it up vastly for large arrays.

denom = sum(XYZ,1);
xy = XYZ(1:2,:)./denom([1 1]',:);
xyY = [xy ; XYZ(2,:)];

% [m,n] = size(XYZ);
% xyY = zeros(m,n);
% for i = 1:n
%  xyY(1,i) = XYZ(1,i)./sum(XYZ(:,i));
%  xyY(2,i) = XYZ(2,i)./sum(XYZ(:,i));
%  xyY(3,i) = XYZ(2,i);
% end

