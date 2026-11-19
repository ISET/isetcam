function tests = test_oiCalculateIrradiance()
tests = functiontests(localfunctions);
end

function testMatchesFormula(~)
%% Irradiance is pi*L/(m^2 + 4N^2(1+|m|)^2)

[scene, oi] = localSetup(0.004, 4, 1.2);
[E, L, m] = localIrradiance(scene, oi);

expected = pi/(m^2 + 4*4^2*(1 + abs(m))^2);
assert(abs(E/L - expected)/expected < 1e-12);

end

function testEnergyConservation(~)
%% Power on the image equals the power entering the lens
%
% A scene patch of area A_s sends L*A_s*pi*sin(alpha)^2 into the entrance
% pupil, and the lens spreads it over m^2*A_s.  So E*m^2 must equal
% pi*L*sin(alpha)^2 for any focal length, f-number, and distance.

cases = [0.004 4    100;     % focal length (m), f-number, distance (m)
         0.004 4    1.2;
         0.004 1.4  0.1;
         0.004 4    0.008;   % 1:1 magnification
         0.017 2.43 1.2];    % human eye, 7 mm pupil
for ii = 1:size(cases,1)
    f = cases(ii,1); N = cases(ii,2); d = cases(ii,3);
    [scene, oi] = localSetup(f, N, d);
    [E, L, m] = localIrradiance(scene, oi);

    a = f/(2*N);
    sin2alpha = a^2/(a^2 + d^2);
    assert(abs(E*m^2/(pi*L*sin2alpha) - 1) < 1e-10);
end

end

function testScalesWithPupilArea(~)
%% Issue #22: irradiance scales with pupil area (human eye, 2 vs 7 mm)

[scene, oi] = localSetup(0.017, 17/2, 1.2);
E2 = localIrradiance(scene, oi);
[scene, oi] = localSetup(0.017, 17/7, 1.2);
E7 = localIrradiance(scene, oi);

% The m^2 term leaves a residual of order m^2/(4N^2), about 1e-5 here
assert(abs((E7/E2)/(7/2)^2 - 1) < 1e-4);

end

function testComputedImageGeometryAndPower(testCase)
%% Finite-distance images preserve sample pitch through padding and cropping.

f = 0.004;
N = 4;
hfov = 1;
sceneSize = [9 13];
scene = sceneCreate('uniform ee',sceneSize,[500 550 600]);
scene = sceneSet(scene,'fov',hfov);
oi = oiCreate('diffraction limited');
oi = oiSet(oi,'optics focal length',f);
oi = oiSet(oi,'optics fnumber',N);
oi = oiSet(oi,'optics offaxis method','skip');
paddedSize = sceneSize + 2*round(sceneSize/8);

for d = [1.2 0.1 0.012 0.008]
    scene = sceneSet(scene,'distance',d);
    imageDistance = f*d/(d-f);
    pitch = 2*imageDistance*tand(hfov/2)/sceneSize(2);
    paddedFOV = 2*atand(paddedSize(2)/sceneSize(2)*tand(hfov/2));

    padded = oiCompute(oi,scene);
    cropped = oiCompute(oi,scene,'crop',true);
    testCase.verifyEqual(oiGet(padded,'size'),paddedSize);
    testCase.verifyEqual(oiGet(cropped,'size'),sceneSize);
    testCase.verifyEqual(oiGet(padded,'hfov'),paddedFOV,'AbsTol',1e-12);
    testCase.verifyEqual(oiGet(cropped,'hfov'),hfov,'AbsTol',1e-12);
    testCase.verifyEqual(oiGet(padded,'sample size'),pitch,'RelTol',1e-12);
    testCase.verifyEqual(oiGet(cropped,'sample size'),pitch,'RelTol',1e-12);
    testCase.verifyEqual(oiGet(cropped,'depth map'),d*ones(sceneSize));

    pupilRadius = f/(2*N);
    pupilFactor = pi*pupilRadius^2/(pupilRadius^2 + d^2);
    scenePitch = sceneGet(scene,'sample size');
    expectedPower = sum(sceneGet(scene,'photons'),[1 2])*scenePitch^2*pupilFactor;
    imagePower = sum(double(oiGet(padded,'photons')),[1 2])*pitch^2;
    testCase.verifyEqual(imagePower,expectedPower,'RelTol',1e-6);
end

end

function testComputeWithRequestedPixelSize(testCase)
%% A requested pitch is set at the image distance and keeps the sample grid.

scene = sceneCreate('uniform ee',[9 13],[500 550 600]);
scene = sceneSet(scene,'distance',0.008);
oi = oiSet(oiCreate('diffraction limited'),'optics focal length',0.004);
pitch = 5e-6;
result = oiCompute(oi,scene,'crop',true,'pixel size',pitch);

testCase.verifyEqual(oiGet(result,'size'),sceneGet(scene,'size'));
testCase.verifyEqual(oiGet(result,'sample size'),pitch,'RelTol',1e-12);
testCase.verifyEqual(oiGet(result,'hfov'),2*atand(13*pitch/(2*0.008)),'AbsTol',1e-12);

end

function testMagnificationFactor(~)
%% A near object reduces the irradiance by (1+|m|)^2 (working f-number)

[scene, oi] = localSetup(0.004, 4, 1e9);   % effectively at infinity
Einf = localIrradiance(scene, oi);
[scene, oi] = localSetup(0.004, 4, 0.008); % 1:1, m = -1
[E1, ~, m] = localIrradiance(scene, oi);

assert(abs(m + 1) < 1e-12);
expected = 4*4^2/(1 + 4*4^2*4);           % (4N^2) / (m^2 + 4N^2(1+|m|)^2)
assert(abs(E1/Einf - expected) < 1e-10);
assert(abs(E1/Einf - 1/4) < 2e-3);

end

function testCappedAtPhysicalLimit(~)
%% Working f-numbers below 0.5 are capped at pi*L

% The f-number that oiCreate('pinhole') uses to suppress diffraction blur
[scene, oi] = localSetup(0.01, 1e-3, 1.2);
[E, L] = localIrradiance(scene, oi);
assert(abs(E/L - pi) < 1e-12);

% At working f-number 0.5 the formula itself reaches the limit
[scene, oi] = localSetup(0.004, 0.5, 1e9);
[E, L] = localIrradiance(scene, oi);
assert(abs(E/L/pi - 1) < 1e-6);

end

function testAccommodatingEye(~)
%% An eye focused by accommodation matches L*pupilArea/eyeLength^2
%
% The retina stays at the eye length.  Setting the focal length to
% 1/(1/dEye + 1/dObj) puts the image there, and the irradiance then equals
% the eye-length formula (as in PTB), apart from the m^2 term.

dEye = 0.017; dObj = 0.25; D = 0.003;   % eye length, object distance, pupil (m)
f = 1/(1/dEye + 1/dObj);
[scene, oi] = localSetup(f, f/D, dObj);
[E, L] = localIrradiance(scene, oi);

assert(abs(opticsGet(oiGet(oi,'optics'),'focal plane distance',dObj) - dEye) < 1e-12);
pupilArea = pi*(D/2)^2;
assert(abs(E/(L*pupilArea/dEye^2) - 1) < 1e-4);

end

function testRayTraceUsesWorkingFNumber(~)
%% Ray-trace optics use the working f-number, with no magnification factor

scene = sceneCreate('uniform ee', 8);
scene = sceneSet(scene, 'distance', 2);   % The lens's object distance
oi = oiCreate('raytrace');
irradiance = oiCalculateIrradiance(scene, oi);
radiance   = sceneGet(scene, 'photons');

Nw = opticsGet(oiGet(oi,'optics'), 'rt effective fnumber');
assert(abs(irradiance(4,4,1)/radiance(4,4,1)/(pi/(4*Nw^2)) - 1) < 1e-12);

end

function testSkipModelUnchanged(~)
%% The skip model has m = -1, where the formula is pi*L/(1 + 16N^2)

[scene, oi] = localSetup(0.004, 4, 1.2);
oi = oiSet(oi, 'optics model', 'skip');
E = oiCalculateIrradiance(scene, oi);
L = sceneGet(scene, 'photons');

assert(max(abs(E(:)./L(:) - pi/(1 + 16*4^2))) < 1e-12);

end

%% ---------------------------------------------------------------------
function [scene, oi] = localSetup(f, N, d)
scene = sceneCreate('uniform ee', 8);
scene = sceneSet(scene, 'distance', d);
oi = oiCreate('diffraction limited');
oi = oiSet(oi, 'optics focal length', f);
oi = oiSet(oi, 'optics fnumber', N);
end

function [E, L, m] = localIrradiance(scene, oi)
irradiance = oiCalculateIrradiance(scene, oi);
radiance   = sceneGet(scene, 'photons');
E = irradiance(4,4,1);
L = radiance(4,4,1);
m = opticsGet(oiGet(oi,'optics'), 'magnification', sceneGet(scene,'distance'));
end
