function middleM = getMiddleMatrix(m,sz)
%Extract values near middle of a matrix.
%
%   middleM = getMiddleMatrix(m,sz)
%
% Data values from the middle of a matrix are returned. The total number
% of extracted pixels is 1 + round(sz/2)*2.  This is awkward  for small
% numbers of sz, but OK for bigger numbers.
%
%  Example:
%     mat = reshape([1:(9*9)],9,9);
%     foo = getMiddleMatrix(mat,3)
%
%     mat = reshape([1:(9*9*3)],9,9,3);
%     foo = getMiddleMatrix(mat,5)
%
% Copyright ImagEval Consultants, LLC, 2003.

sz = round(sz/2);
center = round(size(m)/2);
if (numel(sz) == 1)
    sz(2) = sz(1);
end
rMin = max(1,center(1)-sz(1)); rMax = min(size(m,1), center(1)+sz(1));
cMin = max(1,center(2)-sz(2)); cMax = min(size(m,2), center(2)+sz(2));

r = (rMin:rMax);
c = (cMin:cMax);
w = size(m,3);
middleM = zeros(length(r),length(c),w);

for ii=1:w
    middleM(:,:,ii) = m(r,c,ii);
end

end

