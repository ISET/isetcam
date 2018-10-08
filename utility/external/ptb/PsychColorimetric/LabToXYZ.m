function XYZ = LabToXYZ(Lab,whiteXYZ)
% XYZ = LabToXYZ(Lab,whiteXYZ)
%
% Convert Lab to XYZ.
%
% 10/10/93    dhb   Converted from CAP C code.
% 5/9/02      dhb   Improved help

% Check sizes and allocate
[m,n] = size(Lab);

% Get Y from Lstar
Y = LxxToY(Lab,whiteXYZ);

% Compute F[1] = f(Y/Yn) from Y
% Because subroutine is a vector routine, we put in and get/
% back dummy values for X,Z
fakeXYZ = [Y ; Y ; Y];
F = XYZToF(fakeXYZ,whiteXYZ);

% Compute ratio[0], ratio[2] from a*,b*, and ratio[1] */
F(1,:) = (Lab(2,:)/500.0) + F(2,:);
F(3,:) = F(2,:) - (Lab(3,:)/200.0);
ratio = FToRatio(F);

% Compute XYZ from the ratios
XYZ = ratio .* (whiteXYZ*ones(1,n));
