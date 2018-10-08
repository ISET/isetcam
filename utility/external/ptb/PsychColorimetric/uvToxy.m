function xy = uvToxy(uv,compute1960)
% xy = uvToxy(uv,[compute1960])
%
% Convert CIE u'v' chromaticity to CIE xy chromaticity.
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
% See also uvYToXYZ, XYZTouvY, xyTouv
%
% 7/15/03  dhb, bx  Wrote it.
% 3/17/04  dhb      Fixed typos.  This must not have been tested previously.
% 5/06/11  dhb      Improve comment, optional 1960 computations

%% Handle optional arg
if (nargin < 2 || isempty(compute1960))
    compute1960 = 0;
end

%% Do it, using uvYToXYZ as engine
uvY = [uv ; ones(1,size(uv,2))];
XYZ = uvYToXYZ(uvY,compute1960);
xyY = XYZToxyY(XYZ);
xy = xyY(1:2,:);

