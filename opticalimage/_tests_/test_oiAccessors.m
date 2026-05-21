function tests = test_oiAccessors()
tests = functiontests(localfunctions);
end

function testBareOIDefaultGeometry(~)
%% Bare OIs carry explicit default geometry.

oi = oiCreate;

assert(strcmp(oiGet(oi,'type'),'opticalimage'));
assert(isequal(oiGet(oi,'size'),[256 256]));
assert(oiGet(oi,'rows') == 256);
assert(oiGet(oi,'cols') == 256);
assert(abs(oiGet(oi,'wangular') - 10) < 1e-12);

imageDistance = oiGet(oi,'focal plane distance');
expectedWidth = 2*imageDistance*tand(oiGet(oi,'wangular')/2);
expectedSample = expectedWidth/oiGet(oi,'cols');

assert(abs(oiGet(oi,'width') - expectedWidth) < 1e-15);
assert(abs(oiGet(oi,'height') - expectedSample*oiGet(oi,'rows')) < 1e-15);
assert(abs(oiGet(oi,'sample size') - expectedSample) < 1e-15);
assert(max(abs(oiGet(oi,'sample spacing') - [expectedSample expectedSample])) < 1e-15);
assert(max(abs(oiGet(oi,'distance per sample') - [expectedSample expectedSample])) < 1e-15);

support = oiGet(oi,'spatial support');
linearSupport = oiGet(oi,'spatial support linear');
assert(isequal(size(support),[256 256 2]));
assert(numel(linearSupport.x) == 256);
assert(numel(linearSupport.y) == 256);
assert(abs(linearSupport.x(1) + expectedWidth/2 - expectedSample/2) < 1e-15);
assert(abs(linearSupport.x(end) - expectedWidth/2 + expectedSample/2) < 1e-15);
assert(abs(linearSupport.y(1) + oiGet(oi,'height')/2 - expectedSample/2) < 1e-15);
assert(abs(linearSupport.y(end) - oiGet(oi,'height')/2 + expectedSample/2) < 1e-15);
assert(abs(support(1,1,1) - linearSupport.x(1)) < 1e-15);
assert(abs(support(1,1,2) - linearSupport.y(1)) < 1e-15);

end

function testExplicitSizePreservesWidthAndPixelPitch(~)
%% Explicit row/column size changes dimensions without changing FOV.

oi = oiCreate;
oi = oiSet(oi,'fov',8);
oi = oiSet(oi,'size',[120 180]);

assert(isequal(oiGet(oi,'size'),[120 180]));
assert(oiGet(oi,'rows') == 120);
assert(oiGet(oi,'cols') == 180);
assert(abs(oiGet(oi,'wangular') - 8) < 1e-12);

expectedSample = oiGet(oi,'width')/180;
assert(abs(oiGet(oi,'sample size') - expectedSample) < 1e-15);
assert(abs(oiGet(oi,'height') - 120*expectedSample) < 1e-15);
assert(max(abs(oiGet(oi,'sample spacing') - [expectedSample expectedSample])) < 1e-15);
assert(max(abs(oiGet(oi,'spatial resolution') - [expectedSample expectedSample])) < 1e-15);

support = oiGet(oi,'spatial support linear','mm');
assert(numel(support.x) == 180);
assert(numel(support.y) == 120);
assert(abs((support.x(end) - support.x(1)) - (179*expectedSample*1e3)) < 1e-12);
assert(abs((support.y(end) - support.y(1)) - (119*expectedSample*1e3)) < 1e-12);

end

function testSampleSpacingSetterUpdatesFOV(~)
%% The sample-spacing setter maps requested pitch to horizontal FOV.

oi = oiCreate;
oi = oiSet(oi,'size',[64 96]);

requestedPitch = 4e-6;
focalLength = oiGet(oi,'focal length','m');
expectedFOV = 2*atand(requestedPitch*oiGet(oi,'cols')/(2*focalLength));

oi = oiSet(oi,'sample spacing',requestedPitch);

assert(abs(oiGet(oi,'wangular') - expectedFOV) < 1e-12);

imageDistance = oiGet(oi,'focal plane distance');
expectedWidth = 2*imageDistance*tand(expectedFOV/2);
expectedReportedPitch = expectedWidth/oiGet(oi,'cols');
assert(abs(oiGet(oi,'sample size') - expectedReportedPitch) < 1e-15);

end

function testComputedOIGeometryFollowsScene(~)
%% oiCompute overwrites bare-OI defaults with scene-driven geometry.

scene = sceneCreate('uniform ee',32,500:100:600);
scene = sceneSet(scene,'fov',4);

oi = oiCreate;
oi = oiCompute(oi,scene);

photons = oiGet(oi,'photons');
sceneSize = sceneGet(scene,'size');
padSize = round(sceneSize/8);
expectedSize = sceneSize + 2*padSize;
expectedFOV = 2*atand((1 + (2*padSize(2))/sceneSize(2))* ...
    tand(sceneGet(scene,'wangular')/2));

assert(~isempty(photons));
assert(isequal(oiGet(oi,'size'),[size(photons,1) size(photons,2)]));
assert(isequal(oiGet(oi,'size'),expectedSize));
assert(oiGet(oi,'rows') == size(photons,1));
assert(oiGet(oi,'cols') == size(photons,2));
assert(isequal(oiGet(oi,'wave'),sceneGet(scene,'wave')));
assert(abs(oiGet(oi,'wangular') - expectedFOV) < 1e-12);

sampleSpacing = oiGet(oi,'sample spacing');
spatialResolution = oiGet(oi,'spatial resolution');
assert(max(abs(sampleSpacing - [spatialResolution(2) spatialResolution(1)])) < 1e-15);
assert(abs(oiGet(oi,'width') - sampleSpacing(1)*oiGet(oi,'cols')) < 1e-15);
assert(abs(oiGet(oi,'height') - sampleSpacing(2)*oiGet(oi,'rows')) < 1e-15);

support = oiGet(oi,'spatial support');
assert(isequal(size(support),[oiGet(oi,'rows') oiGet(oi,'cols') 2]));
assert(abs(support(1,1,1) + oiGet(oi,'width')/2 - sampleSpacing(1)/2) < 1e-15);
assert(abs(support(1,end,1) - oiGet(oi,'width')/2 + sampleSpacing(1)/2) < 1e-15);
assert(abs(support(1,1,2) + oiGet(oi,'height')/2 - sampleSpacing(2)/2) < 1e-15);
assert(abs(support(end,1,2) - oiGet(oi,'height')/2 + sampleSpacing(2)/2) < 1e-15);

end
