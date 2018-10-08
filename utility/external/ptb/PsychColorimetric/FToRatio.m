function ratio = FToRatio(F)
% ratio = FToRatio(F)
%
% This is related to Lab calculations.
%
% 10/10/93    dhb   Converted from CAP C code.

% Find sizes and allocate
[m,n] = size(F);
ratio = zeros(m,n);

% Compute according to the range
hIndex = find( F > 0.206893);
lIndex = find( F <= 0.206893);
if (~isempty(hIndex))
  ratio(hIndex) = F(hIndex).^3.0;
end
if (~isempty(lIndex))
  ratio(lIndex) = (F(lIndex)-(16.0/116.0)*ones(length(lIndex),1))/7.787;
end
  
