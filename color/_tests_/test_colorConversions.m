function tests = test_colorConversions()
tests = functiontests(localfunctions);
end

function testSRGBTransferFunctionNumericalValues(~)
%% sRGB transfer functions match standard breakpoints and round-trip

linearRGB = reshape([0 0 0; ...
    0.0031308 0.0031308 0.0031308; ...
    0.18 0.18 0.18; ...
    1 1 1],[4 1 3]);

srgb = lrgb2srgb(linearRGB);
expectedSRGB = reshape([0 0 0; ...
    0.040449936 0.040449936 0.040449936; ...
    0.4613561295 0.4613561295 0.4613561295; ...
    1 1 1],[4 1 3]);

assert(max(abs(srgb(:) - expectedSRGB(:))) < 1e-9);
assert(max(abs(srgb2lrgb(srgb) - linearRGB),[],'all') < 1e-12);

end

function testLinearRGBToXYZNumericalValues(~)
%% Linear sRGB primaries map to standard D65 XYZ coordinates

linearRGB = reshape([1 0 0; ...
    0 1 0; ...
    0 0 1; ...
    1 1 1],[4 1 3]);

xyz = imageLinearTransform(linearRGB,colorTransformMatrix('lrgb2xyz'));
expectedXYZ = reshape([0.4124 0.2126 0.0193; ...
    0.3576 0.7151 0.1192; ...
    0.1805 0.0721 0.9505; ...
    0.9504 0.9999 1.0891],[4 1 3]);

assert(max(abs(xyz(:) - expectedXYZ(:))) < 5e-5);

srgbXYZ = colorTransformMatrix('srgb2xyz');
xyzFromXW = RGB2XWFormat(linearRGB)*srgbXYZ;
xyzXW = RGB2XWFormat(xyz);
assert(max(abs(xyzFromXW(:) - xyzXW(:))) < 1e-12);

end

function testXYZToSRGBNumericalValues(~)
%% XYZ values convert to expected sRGB values and report scaling

xyz = reshape([0.9504 0.9999 1.0891; ...
    0.4124 0.2126 0.0193; ...
    0.1711 0.1800 0.1960],[3 1 3]);

[srgb,linearRGB,maxY] = xyz2srgb(xyz);

expectedSRGB = reshape([1 1 1; ...
    1 0 0; ...
    0.4614 0.4614 0.4614],[3 1 3]);
expectedLinearRGB = reshape([1 1 1; ...
    1 0 0; ...
    0.18 0.18 0.18],[3 1 3]);

assert(maxY == 1);
assert(max(abs(srgb(:) - expectedSRGB(:))) < 5e-4);
assert(max(abs(linearRGB(:) - expectedLinearRGB(:))) < 5e-4);

xyzRoundTrip = srgb2xyz(srgb);
assert(max(abs(xyzRoundTrip(:) - xyz(:))) < 5e-4);

end

function testXYZToSRGBScalesHighLuminanceInputs(~)
%% xyz2srgb scales inputs whose luminance is above one

xyz = reshape([0.9504 2.0 1.0891],[1 1 3]);

[~,~,maxY] = xyz2srgb(xyz);

assert(maxY == 2.0);

end
