function [dEab, errComponents] = deltaEab(xyz1,xyz2,whitePnt,deltaEVer)
%Gateway routine for calculating delta E between corresponding XYZ values
%
%   [dEab, errComponents] = deltaEab(XYZ1,XYZ2,whitePnt,[deltaEVer='2000'])
%
% Calculate the CIE delta E between two different colors in CIELAB space.
%
% The CIE delta E standard is a fundamental tool of color science.  The
% metric is described in a wide variety of textbooks.  It has gone through
% a series of refinements over the years.  The latest is this one, the
% CIEDE2000.  Earlier versions, dating to 1976, were also defined.
%
% XYZ1 and XYZ2 define the corresponding sets of XYZ data.  These are
% stored either XW (space-wavelength) or RGB Image format.
%
% If the data are XW format, then they a are (n*m, 3) matrices. In RGB
% image format they are 3D arrays of n x m x 3.
%
% whitePnt is the white point for the CIELAB calculation.  If whitePnt is a
% cell array, then the first entry is the white point of xyz1 and the
% second of xyz2.
%
% In the normal (full delta E) mode, deltaEVe refers to the year of the
% delta E calculation: '1976','1994' or '2000'. The default is 2000. It is
% also possible to request only the luminance or chrominance part of the
% delta E error.  In this case, the deltaEVer is 'chroma' or 'luminance'.
% These are always based on the CIELAB 2000 code.
%
% The returned dEab values have the same format (XW or RGB) as the input
% XYZ values.
%
% Example:
%  dataXYZ1 = imageDataXYZ(vci1,roiLocs); whitePnt{1} = ipGet(vci1,'whitepoint');
%  dataXYZ2 = imageDataXYZ(vci2,roiLocs); whitePnt{2} = ipGet(vci2,'whitepoint');
%  dEab = deltaEab(dataXYZ1,dataXYZ2,whitePnt)
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('deltaEVer'), deltaEVer='2000'; end;

if ndims(xyz1) == 3
    if size(xyz1,3) ~= 3, error('xyz1 must be RGB or XW format'); end
elseif ndims(xyz1) == 2
    if size(xyz1,2) ~= 3, error('xyz1 must be RGB or XW format'); end
end

if ndims(xyz2) == 3
    if size(xyz2,3) ~= 3, error('xyz2 must be RGB or XW format'); end
elseif ndims(xyz2) == 2
    if size(xyz2,2) ~= 3, error('xyz2 must be RGB or XW format'); end
end

% Compute LAB values
% Use modern code
useOldCode = 0;
if iscell(whitePnt)
    a = ieXYZ2LAB(xyz1, whitePnt{1}, useOldCode);
    b = ieXYZ2LAB(xyz2, whitePnt{2}, useOldCode);
else
    a = ieXYZ2LAB(xyz1,whitePnt, useOldCode);
    b = ieXYZ2LAB(xyz2,whitePnt, useOldCode);
end

% Determine format (3D or XW)
n = ndims(a);
if n == 3
    [a,ra,ca,wa]=RGB2XWFormat(a);
    [b,rb,cb,wb]=RGB2XWFormat(b);
end;

% We calculate one of several possible delta E formulae. We also check
% whether the user wants just the luminance, chrominance, or hue errors
errComponents = [];
switch deltaEVer
    case '2000'
        de = deltaE2000(a, b);
    case '1994'
        de = deltaE94(a, b);
    case '1976'
        % Here is the LAB difference from a simpler era.
        d = a - b;
        de = sqrt(sum(d.^2,2));
    case {'luminance','hue','chrominance','all'}
        [de, errComponents] = deltaE2000(a, b);
    otherwise
        error('Unknown DeltaE type: %s.', deltaEver);
end;

% If needed, reshape the delta E and errComponent values to RGB.
% Otherwise, they remain as a long vector.
if n ==3
    dEab = reshape(de, [ra, ca]);
    if ~isempty(errComponents)
        errComponents.dL = reshape(errComponents.dL, [ra, ca]);
        errComponents.dC = reshape(errComponents.dC, [ra, ca]);
        errComponents.dH = reshape(errComponents.dH, [ra, ca]);
        errComponents.RT = reshape(errComponents.RT, [ra, ca]);
    end
elseif n == 2
    dEab=de;
end;

return;
