function xyz = ieLAB2XYZ(lab, whitepoint, useOldCode, exp)
% Convert CIE LAB values to CIE XYZ values
%
%    xyz = ieLAB2XYZ(lab,whitepoint,exp,useOldCode)
%
% Converts CIEL*a*b* coordinates to CIE XYZ coordinates.  We will use the
% makecform routine from the Matlab image processing toolbox for the
% converison; if the toolbox/routine is not available, we will revert to
% the older version of the code.
%
% lab        - LAB image; can either be in XW or RGB format.
% whitepoint - a 3-vector of the xyz values of the white point.
% useOldCode - 0 to use Matalb's routines, 0 otherwise
% exp        - used by old code; the exponent used in the CIELAB formula.
%              Default is cube root as used in standard CIELAB. If
%              specified, use the number as exponent. (note this exponent
%              here should be the same as the exponent used in vcXYZlab.m)
%
% Examples:
%  vci = vcGetObject('vcimage');
%  [locs,rgb] = macbethSelect(vci);
%  dataXYZ = imageRGB2xyz(vci,rgb);
%  whiteXYZ = dataXYZ(1,:);
%  lab = ieXYZ2LAB(dataXYZ,whiteXYZ);
%  xyz = ieLAB2XYZ(lab,whitepoint,exp,useOldCode)
%
% See also:  ieXYZ2LAB
%
% Copyright ImagEval Consultants, LLC, 2009.

if ieNotDefined('lab'), error('No data.'); end
if ieNotDefined('whitepoint')
    error('A whitepoint is required for conversion to CIELAB (1976).');
    end
    if ieNotDefined('useOldCode'), useOldCode = 0; end
    if ieNotDefined('exp'), if useOldCode, exp = 3;
        end;
    end

    if exist('makecform', 'file') && ~useOldCode

        % Which version of LAB is this for? 1976.
        % We are worried about the white point.

        cform = makecform('lab2xyz', 'WhitePoint', whitepoint(:)');
        xyz = applycform(lab, cform);

        return;

    else

        if length(whitepoint) ~= 3
            error('White point is not a three-vector');
        else
            Xn = whitepoint(1);
            Yn = whitepoint(2);
            Zn = whitepoint(3);
        end

        % We will always work in XW format. If input is in RGB format, we
        % reshape it
        if ndims(lab) == 3
            [r, c, w] = size(lab);
            lab = RGB2XWFormat(lab);
        end

        % Usual formula for Lstar.   (y = Y/Yn)
        fy = (lab(:, 1) + 16) / 116;
        y = fy.^exp;

        % Find out cases where (Y/Yn) is too small and use other formula
        % Y/Yn = 0.008856 correspond to L=7.9996
        yy = find(lab(:, 1) <= 7.9996);
        y(yy) = lab(yy, 1) / 903.3;
        fy(yy) = 7.787 * y(yy) + 16 / 116;

        % find out fx, fz
        fx = lab(:, 2) / 500 + fy;
        fz = fy - lab(:, 3) / 200;

        % find out x=X/Xn, z=Z/Zn
        % when (X/Xn)<0.008856, fx<0.206893
        % when (Z/Zn)<0.008856, fz<0.206893
        xx = find(fx < .206893);
        zz = find(fz < .206893);
        x = fx.^exp;
        z = fz.^exp;
        x(xx) = (fx(xx) - 16 / 116) / 7.787;
        z(zz) = (fz(zz) - 16 / 116) / 7.787;

        xyz = [x * Xn, y * Yn, z * Zn];

        % Return XYZ in appropriate shape
        if ndims(xyz) == 3, xyz = XW2RGBFormat(xyz, r, c); end

    end

    return;
