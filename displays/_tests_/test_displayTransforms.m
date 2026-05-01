function tests = test_displayTransforms()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% v_displayTransforms
%
% Test display transforms between spaces
%
% Check RGB2XYZ and XYZ2LMS and RGB2LMS relationships

%%
ieInit

%% Test display transforms between spaces

% This Apple display has a peak luminance of about 120 cd/m2
d = displayCreate('LCD-Apple');

% Here is the transform
rgb2xyz = displayGet(d,'rgb2xyz');

% [1 0 0]* rgb2xyz;
whiteXYZ = [1 1 1]* rgb2xyz;

assert(max(abs(whiteXYZ - [108.6659  118.1495  121.0519])) < 1e-4);
assert(max(abs(displayGet(d,'white point') - [108.6659  118.1495  121.0519])) < 1e-4);

%% Now let's check out the rgb2lms calculation

% The lms in this case is the Stockman
rgb2lms = displayGet(d,'rgb2lms');
LMS = [1 1 1]*rgb2lms;
assert(max(abs(LMS - [0.0461    0.0400    0.0231])) < 1e-4);


%% Compare the colorTransformMatrix with the calculated Stockman

% Master calculation - not wavelength sampling depend, so only approximate
xyz2lms = colorTransformMatrix('xyz2lms');
lms2xyz = colorTransformMatrix('lms2xyz');

% Compare rgb2lms with rgb2xyz * xyz2lms
srgb2xyz = colorTransformMatrix('srgb2xyz');
xyz2srgb = colorTransformMatrix('xyz2srgb');
assert( max(max(abs(srgb2xyz*xyz2srgb - eye(3,3)))) < 1e-10);

% Calculate it
w = 400:10:700;
xyz = ieReadSpectra('XYZ.mat',w);
stockman = ieReadSpectra('stockman',w);

% XYZ = Stockman * sto2xyz
sto2xyz = stockman \ xyz;
xyz2sto = xyz \ stockman;

% This should be close to 1 everywhere
tmp = (xyz2lms ./ xyz2sto - 1).^2;
assert( sqrt(mean(tmp(:))) < 1e-2)

tmp = (lms2xyz ./ sto2xyz - 1).^2;
assert( sqrt(mean(tmp(:))) < 1e-1)

%% END



end
