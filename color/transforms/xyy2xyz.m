function xyz = xyy2xyz(xyy)
% Convert data from CIE xyY to CIE XYZ values
%
%       xyz = xyy2xyz(xyy)
%
% Purpose:
%    It is common to represent the color of a light using xyY (chromaticity
%    coordinates and luminance). This routine converts from the xyY
%    representation to the standard XYZ representation. 
%
%    The values are all represented in n X 3 format.  For XYZ, the first
%    column is X, second  column is Y and third is Z.  Similarly, the
%    input columns must be x,y, and Y. 
%
% Formula:
%    X = (x/y)*Y, 
%    Z = ((1 - x - y)/y) * Y
%    Also, note that Y/y = X+Y+Z
%
% Copyright ImagEval Consultants, LLC, 2003.

if size(xyy,2) ~= 3
    error('Input must be x,y,Y in the rows.')
end

xyz = zeros(size(xyy));

% = Y
xyz(:,2) = xyy(:,3);

% X + Y + Z = Y/y
sXYZ = xyy(:,3)./xyy(:,2);

% X = (x/y)*Y
xyz(:,1) = (xyy(:,1)./xyy(:,2)) .* xyy(:,3);

% Z = (X + Y + Z) - Y - X
xyz(:,3) = sXYZ - xyy(:,3) - xyz(:,1);

return;

