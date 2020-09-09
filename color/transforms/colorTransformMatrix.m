function result = colorTransformMatrix(matrixtype,spacetype)
%Gateway routine that returns color space transformation matrices
%
%  result = colorTransformMatrix(matrixtype,spacetype)
%
% The routine returns a 3x3 color matrix, MAT, suitable for use with
% rgbLinearTransform, to convert an NxMx3 color image from one color
% space to another.
%
% Suppose a point is represented by the row vector, p = [R,G,B].
% The matrix transforms each color point, p, to an output vector pT
%
% This routine works with imageLinearTransform
%
%   T = colorTransformMatrix('lms2xyz');
%   xyzImage = imageLinearTransform(lmsImage,T)
%
% returns an NxMx3 xyz Image as expected
%
% matrixtypes are:
%    'lms2opp' -- cone coordinate to opponent (Poirson & Wandell 1993)
%    'opp2lms' -- inverse of the above matrix
%    'xyz2opp' -- xyz to opponent (CIE1931 2 degree XYZ)
%    'opp2xyz' -- inverse of the above matrix
% 
%    Normalized for D65 (lms=[100 100 100] for D65)
%    'lms2xyz' -- cone coordinate to XYZ (Hunt-Pointer-Estevez transform)
%    'xyz2lms' -- xyz to LMS             (Hunt-Pointer-Estevez transform)
%
%    'xyz2yiq' -- convert from XYZ to YIQ
%    'yiq2xyz' -- inverse of the abvoe matrix
%    'rgb2yuv' -- convert from RGB to YUV (YCbCr) for JPEG compression
%    'yuv2rgb' -- inverse of the above matrix
%    'xyz2srgb' -- from XYZ to sRGB values
%    'srgb2xyz' -- inverse of the above matrix
%             (the above are not dependent on device calibration)
%
%    We added lrgb, which does the same as srgb, to be a little
%    clearer about the fact that this matrix is really in linear (0,1) space,
%    not in the framebuffer (0,255) nonlinear space.
%    'xyz2lrgb' -- from XYZ to lRGB values
%    'lrgb2xyz' -- inverse of the above matrix
%    'cmy2rgb'  -- converts cyan, magenta, yellow to RGB
%
% Examples:
%  The first example is designed around sRGB issues.  See notes in the code
% and wikipedia srgb page.
%
% Suppose we have a monitor whose peak luminance is 75 cd/m2.
% To determine the lRGB for some XYZ value, say XYZ = (30,50,20) and
% we calculate as follows:
%
%    XYZ = [30,50,20];  XYZ = XYZ/75;  chromaticity(XYZ)
%
% We divide because the matrix maps unit luminance for RGB =(1,1,1) and the
% actual luminance is 75.
%
%    m = colorTransformMatrix('xyz2lrgb');
%    lRGB = XYZ*m   % This describes linear RGB for a 75 cd/m2 max
%
% To return to XYZ given that it is a 75 cd/m2 display we do this:
%    m = colorTransformMatrix('lrgb2xyz');
%    unscaledXYZ = lRGB*m;
%    estXYZ = unscaledXYZ*75
%
% More Examples:
%
%    (luminance, red-green, blue-yellow)
%    T = colorTransformMatrix('xyz2opp')
%    p = [70    70    40]; p*T
%
%  Make an image of the XYZ matching functions:
%    XYZ = ieReadSpectra('XYZ.mat',370:730); imXYZ = zeros(361,20,3);
%    for ii=1:3, imXYZ(:,:,ii) = repmat(XYZ(:,ii),1,20); end
%    T = colorTransformMatrix('xyz2srgb');
%    imRGB = imageLinearTransform(imXYZ,T);
%    imagescRGB(imRGB);
%
%  Convert between XYZ and Stockman fundamentals
%   wave = 400:5:700;
%   xyz = ieReadSpectra('XYZ',wave);
%   stock = ieReadSpectra('Stockman',wave);
%   T = colorTransformMatrix('stockman 2 xyz');
%   pred = stock*T; plot(xyz(:),pred(:),'.'); axis equal; grid on
%
%  Notice, these aren't perfect inverses.  Maybe they should be?  But
%  Stockman and XYZ are not within a perfect linear transformation.
%   T1 = colorTransformMatrix('stockman 2 xyz');
%   T2 = colorTransformMatrix('xyz 2 stockman');
%   T1*T2
%
% See also: colorTransformMatrixCreate
%
% Copyright ImagEval Consultants, LLC, 2003.

% Programming Note: When Xuemei originally built this list, she had in mind
% T3x3*colVector At ImagEval, we use rowVector*T3x3.  We retained her terms
% but we return the transpose of her result (see the end).

if ieNotDefined('matrixtype'), error('Matrix type required.'); end
if ieNotDefined('spacetype'),  spacetype = []; end

matrixtype = ieParamFormat(matrixtype);

switch lower(matrixtype)
    case {'lms2opp'}
        result = [0.9900   -0.1060   -0.0940; ...
            -0.6690    0.7420   -0.0270; ...
            -0.2120   -0.3540    0.9110];

    case {'opp2lms'}
        result = inv([0.9900   -0.1060   -0.0940; ...
            -0.6690    0.7420   -0.0270; ...
            -0.2120   -0.3540    0.9110]);

        % Gosh, these are old from XZ times.  Replaced with Stockman in
        % 2012, now that we are starting to perform cone calculations.
        %
    case {'hpe2xyz'}
        % Hunt-Pointer-Estevez transformation from cone
        % to XYZ, normalized for D65 (lms=[100 100 100] for D65).
        result = inv([.4002  .7076 -.0808; ...
            -.2263 1.1653  .0457; ...
            .0     .0     .9182]);

    case {'xyz2hpe'}
        % Inverse of Hunt-Pointer-Estevez transformation from cone
        % to XYZ, normalized for D65 (lms=[100 100 100] for D65).
        result = [0.4002    0.7076   -0.0808; ...
            -0.2263    1.1653    0.0457; ...
            0         0         0.9182];

    case {'xyz2sto','xyz2stockman','xyz2lms'}
        % Stockman cone coordinates
        result = [ 0.2689   -0.3962    0.0214;
            0.8518    1.1770   -0.0247;
            -0.0358    0.1055    0.5404]';

    case {'stockman2xyz','sto2xyz','lms2xyz'}
        % Stockman cone coordinates
        result = [1.7910    0.6068   -0.0432;
            -1.2884    0.4097    0.0697;
            0.3702   -0.0398    1.8340]';

    case {'xyz2opp','opp2xyz'}
        if ieNotDefined('spacetype'), spacetype = 10; end
        if (spacetype == 2)
            result = [278.7336  721.8031 -106.5520; ...
                -448.7736  289.8056   77.1569; ...
                85.9513 -589.9859  501.1089]/1000;
        elseif (spacetype == 10)
            result = [ 288.5613  659.7617 -130.5654; ...
                -464.8864  326.2702   62.4200; ...
                79.8787 -554.7976  481.4746]/1000;
        end
        if matrixtype(1) == 'o', result = inv(result); end

    case {'xyz2yiq','yiq2xyz' }
        result = [     0    1.0000         0; ...
            1.4070   -0.8420   -0.4510; ...
            0.9320   -1.1890    0.2330];
        if matrixtype(1) == 'y', result = inv(result); end

    case {'rgb2yuv' , 'yuv2rgb'}
        result = [ 0.299   0.587   0.114; ...
            -0.1687 -0.3313  0.5; ...
            0.5    -0.4187 -0.0813];
        if (matrixtype(1) == 'y'), result = inv(result); end

    case{'xyz2srgb','srgb2xyz'}
        % On the Wikipedia page
        % http://en.wikipedia.org/wiki/SRGB
        % Notice the following odd thing from that page:
        %
        % The intermediate parameters Rlinear, Glinear and Blinear for
        % in-gamut colors are defined to be in the range [0,1], which means
        % that the initial X, Y, and Z values need to be similarly scaled
        % (if you start with XYZ values going to 100 or so, divide them by
        % 100 first, or apply the matrix and then scale by a constant
        % factor to the [0,1] range). The linear RGB values are usually
        % clipped to that range, with display white represented as (1,1,1);
        % the corresponding original XYZ values are such that white is D65
        % with unit luminance (X,Y,Z = 0.9505, 1.0000, 1.0890).
        % Calculations assume the 2° standard colorimetric observer.[3]

        result = [3.241  -1.5374 -0.4986; ...
            -0.9692  1.8760  0.0416; ...
            0.0556 -0.2040  1.0570];
        % If user wanted srgb2xyz, we invert the matrix
        if (matrixtype(1) == 's'), result = inv(result);  end

    case{'xyz2lrgb', 'lrgb2xyz'}
        % Only type in the values once.  Here, we get them from the once.
        % For these transformations (see above) RGB and XYZ are supposed to
        % be in the [0,1] range.  We can't figure out why XYZ is not in
        % real units.  Under discussion at Imageval.
        result = [3.241  -1.5374 -0.4986; ...
            -0.9692  1.8760  0.0416; ...
            0.0556 -0.2040  1.0570];
        % If user wanted lrgb2xyz, we invert the matrix
        if (matrixtype(1) =='l'),  result = inv(result);    end

    case{'cmy2rgb','rgb2cmy'}
        % These are used for sensor display purposes.  Sometimes we have a CMY
        % sensor coded in the 3 plane format.  We would like to display the CMY.
        % Matlab treats the data as RGB.  So, we need to convert the data prior to
        % display, so it looks right.  Used in sensorWindow and ipWindow.
        if (matrixtype(1) == 'c')
            result = [0 1 1; ...
                1 0 1 ; ...
                1 1 0];
        else
            result = [0 1 1; ...
                1 0 1 ; ...
                1 1 0];
        end
    otherwise
        error('Unknown matrix type')
end

% This format works with imageLinearTransform
result = result';

end

