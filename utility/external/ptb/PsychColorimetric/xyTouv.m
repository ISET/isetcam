function uv = xyTouv(xy,compute1960)
% uv = xyTouv(xy,[compute1960])
%
% Convert CIE xy chromaticity to CIE u'v' chromaticity.
%
% These are u',v' chromaticity coordinates in notation
% used by CIE.  See CIE Colorimetry 2004 publication, or Wyszecki
% and Stiles, 2cd, page 165.
%
% Note that there is an obsolete u,v chromaticity diagram that is similar
% but uses 6 in the numerator for v rather than the 9 that is used for v'.
% See CIE Colorimetry 2004, Appendix A, or Judd and Wyszecki, p. 296. If
% you want this (maybe to compute correlated color temperatures), you can
% pass this as 1.  It is 0 by default.
%
% 7/15/03  dhb, bx  Wrote it.
% 3/17/04  dhb      Fixed typos.  This must not have been tested previously.
% 5/06/11  dhb      Added optional 1960 computation, and improved comments.

%% Handle optional arg
if (nargin < 2 || isempty(compute1960))
    compute1960 = 0;
end

xyY = [xy ; ones(1,size(xy,2))];
XYZ = xyYToXYZ(xyY);
uvY = XYZTouvY(XYZ,compute1960);
uv = uvY(1:2,:);

% One could check with direct computation from
% published formulae (CIE, Colorimetry, p. 54.)
% We checked for a few values and then commented this out.
% uvCheck = zeros(size(uv));
% uvCheck(1) = 4*xy(1)/(-2*xy(1)+12*xy(2)+3);
% uvCheck(2) = 9*xy(2)/(-2*xy(1)+12*xy(2)+3);
