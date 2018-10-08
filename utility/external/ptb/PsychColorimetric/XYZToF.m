function F = XYZToF(XYZ,white)
% F = XYZToF(XYZ,white)
%
% Compute the F function ratio from XYZ.
% This is used in Lab calculations.
%
% 10/10/93    dhb   Converted from CAP C code.

% Find size of data
[m,n] = size(XYZ);
F = zeros(m,n);

% Compute the ratios w.r.t. white point
ratio = XYZ ./ (white*ones(1,n));

% Compute F from ratio
lIndex = find(ratio <= 0.008856);
hIndex = find(ratio > 0.008856);
if (~isempty(hIndex))
  F(hIndex) = ratio(hIndex).^(1.0/3.0);
end
if (~isempty(lIndex))
  F(lIndex) = 7.787*ratio(lIndex) + (16.0/116.0)*ones(length(lIndex),1);
end

