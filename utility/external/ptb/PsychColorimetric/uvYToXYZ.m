function XYZ = uvYToXYZ(uvY,compute1960)
% XYZ = uvYToXYZ(uvY,[compute1960])
%
% Compute tristimulus coordinates from chromaticity and luminance.
%
% These are u',v' chromaticity coordinates in notation
% used by CIE.  See CIE Colorimetry 2004 publication, or Wyszecki
% and Stiles, 2cd, page 165.
%
% Note that there is an obsolete u,v chromaticity diagram that is similar
% but uses 6 in the numerator for u rather than the 9 that is used for u'.
% See CIE Coloimetry 2004, Appendix A, or Judd and Wyszecki, p. 296. If
% you want this (maybe to compute correlated color temperatures), you can
% pass this as 1.  It is 0 by default.
%
% See also XYZTouvY, xyTouv, XYZToxyY, xyYToXYZ
%
% 10/31/94	dhb  Wrote it.
% 5/06/11   dhb  Improve comment.

%% Handle optional arg
if (nargin < 2 || isempty(compute1960))
    compute1960 = 0;
end

%% To handle 1960 input, take advantage of
% fact that all we need to do is scale v
% to get v'.  Then everything else flows
% as if we had passed u',v'.
if (compute1960)
    uvY(2,:) = uvY(2,:)*(9/6);
end

%% Do the computation
[m,n] = size(uvY);
XYZ = zeros(m,n);
for i = 1:n
  XYZ(1,i) = (9/4)*uvY(3,i)*uvY(1,i)/uvY(2,i);
  XYZ(2,i) = uvY(3,i);
  denom = 9*uvY(3,i)/uvY(2,i);
  XYZ(3,i) = (denom - XYZ(1,i)-15*XYZ(2,i))/3;
end
