function uvY = XYZTouvY(XYZ,compute1960)
% uvY = XYZTouvY(XYZ,[compute1960])
%
% Compute chromaticity and luminance from from tristimulus values.
%
% These are u',v' chromaticity coordinates in notation
% used by CIE.  See CIE Colorimetry 2004 publication, or Wyszecki
% and Stiles, 2cd, page 165.
%
% Note that there is an obsolete u,v chromaticity diagram that is similar
% but uses 6 in the numerator for v rather than the 9 that is used for v'.
% See CIE Colorimetry 2004, Appendix A, or Judd and Wyszecki, p. 296.  If
% you want this (maybe to compute correlated color temperatures), you can
% pass this as 1.  It is 0 by default.
%
% See also uvYToXYZ, XYZToxyY, xyYToXYZ.
%
% 10/31/94  dhb	Wrote it.
% 8/24/09   dhb Speed it up a lot by preallocating output.
% 6/16/10   dhb More extensive comment.
% 5/6/11    dhb Comment fix.
%           dhb Add "compute1960" option.

%% Handle optional arg
if (nargin < 2 || isempty(compute1960))
    compute1960 = 0;
end

%% Do the computation
uvY = NaN*zeros(size(XYZ));
[m,n] = size(XYZ);
for i = 1:n
  denom = (XYZ(1,i) + 15*XYZ(2,i) + 3*XYZ(3,i));
  uvY(1,i) = 4*XYZ(1,i)/denom;
  if (compute1960)
      uvY(2,i) = 6*XYZ(2,i)/denom;
  else
      uvY(2,i) = 9*XYZ(2,i)/denom;
  end
  uvY(3,i) = XYZ(2,i);
end

%% This, I think is a vectorized method.  Not
% sure why it is not used above, but didn't feel
% like finding out today, in case there is some
% good reason (memory limits?)
%
% denom = XYZ(1,:) + 15*XYZ(2,:) + 3*XYZ(3,:);
% uvY = (diag([4 9 1])*XYZ)./denom([1 1 1]',:);
