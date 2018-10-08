function uv = XYZTouv(XYZ,compute1960)
% uv = XYZTouv(XYZ,[compute1960])
%
% Compute uv from XYZ.
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
% 10/10/93  dhb   Created by converting CAP C code.
% 5/06/11   dhb   More extensive comment.  Optional 1960 version. 

%% Handle optional arg
if (nargin < 2 || isempty(compute1960))
    compute1960 = 0;
end

%% Find size and allocate
[m,n] = size(XYZ);
uv = zeros(2,n);

% Compute u and v
denom = [1.0,15.0,3.0]*XYZ;
uv(1,:) = (4*XYZ(1,:)) ./ denom(1,:);
if (compute1960)
    uv(2,:) = (6*XYZ(2,:)) ./ denom(1,:);
else
    uv(2,:) = (9*XYZ(2,:)) ./ denom(1,:);
end
