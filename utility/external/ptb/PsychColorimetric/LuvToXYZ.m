function XYZ = LuvToXYZ(Luv,whiteXYZ)
% XYZ = LuvToXYZ(Luv,whiteXYZ)
%
% 10/10/93    dhb   Converted from CAP C code.
% 5/9/02      dhb   Improved help.

% Get white point u and v
uv0 = XYZTouv(whiteXYZ); 

% Compute Y
Y = LxxToY(Luv,whiteXYZ);

% Compute u,v from ustar and vstar
u = (Luv(2,:) ./ (13.0 * Luv(1,:)) ) + uv0(1);
v = (Luv(3,:) ./ (13.0 * Luv(1,:)) ) + uv0(2);

% Compute XYZ from Yuv
X = (9.0 / 4.0) * (u./v) .*  Y;
Z = ( ((4.0 - u).*X)./(3.0*u) ) - (5.0 * Y);

% Put together the answer   
XYZ = [X ; Y ; Z];



