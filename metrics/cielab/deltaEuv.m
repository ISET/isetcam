function dEuv = deltaEuv(xyz1,xyz2,whitePnt)
% Compute delta E_uv from corresponding CIE XYZ values and a white point
%
%    dEuv = deltaEuv(xyz1,xyz2,whitePnt)
%
% The white point can be a cell array with the white point for each of the
% two XYZ values, or it can be a single vector that applies to both of the
% XYZ data sets.
%
% ARGUMENTS
%   xyz matrices are either XW  or RGB Image format.
%      If the data are XW format, then they a are (n*m, 3) matrices.
%      In RGB image format they are 3D arrays of n x m x 3.
%   whitePnt is the white point for the CIELAB calculation.  1x3 or 3x1 is OK.
%
% RETURNS
%    dEuv is an array of delta E values. It has the same format as the
%    input xyz (XW or RGB).
%
% Example:
%
%  whitePnt = ipGet(vci,'whitepoint');
%  dataXYZ1 = imageDataXYZ(vci1,roiLocs);
%  dataXYZ2 = imageDataXYZ(vci2,roiLocs);
%  dEuv = deltaEuv(dataXYZ1,dataXYZ2,whitePnt)
%
% Copyright ImagEval Consultants, LLC, 2003.

if ndims(xyz1) == 3
    if size(xyz1,3) ~= 3
        error('xyz1 must be RGB or XW format');
    end
elseif ndims(xyz1) == 2
    if size(xyz1,2) ~= 3
        error('xyz1 must be RGB or XW format');
    end
end

if iscell(whitePnt)
    a = xyz2luv(xyz1,whitePnt{1});
    b = xyz2luv(xyz2,whitePnt{2});
else
    a = xyz2luv(xyz1,whitePnt);
    b = xyz2luv(xyz2,whitePnt);
end

% Here is the LUV difference.
d = a - b;

%  Compute the norm of the difference
%  I think this could be dEuv = norm(d,'fro'); -- BW
if ndims(d) == 3        % RGB Format, sum across the planes.
    dEuv = sqrt(sum(d.^2,3));
elseif ndims(d) == 2    % XW Format, sum across the columns
    dEuv = sqrt(sum(d.^2,2));
end

return;

