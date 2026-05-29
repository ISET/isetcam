function tests = test_oiTransforms()
tests = functiontests(localfunctions);
end

function testCropGeometryAndPhotons(~)
%% oiCrop selects the requested photon block and updates FOV.

oi = localTransformOI([6 8]);
photons = oiGet(oi,'photons');

rect = [3 2 2 3];  % [x y width height]
baseSpacing = oiGet(oi,'distance per sample');
focalLength = oiGet(oi,'optics focal length');

cropped = oiCrop(oi,rect);
croppedPhotons = oiGet(cropped,'photons');

expectedPhotons = photons(2:5,3:5,:);
expectedFOV = 2*atand((rect(3)+1)*baseSpacing(2)/(2*focalLength));

assert(isequal(oiGet(cropped,'size'),[rect(4)+1 rect(3)+1]));
assert(max(abs(croppedPhotons(:) - expectedPhotons(:))) < 1e-12);
assert(abs(oiGet(cropped,'fov') - expectedFOV) < 1e-12);
assert(~isempty(oiGet(cropped,'illuminance')));

support = oiGet(cropped,'spatial support');
sampleSpacing = oiGet(cropped,'sample spacing');
assert(isequal(size(support),[4 3 2]));
assert(abs(support(1,1,1) + oiGet(cropped,'width')/2 - sampleSpacing(1)/2) < 1e-15);
assert(abs(support(end,1,2) - oiGet(cropped,'height')/2 + sampleSpacing(2)/2) < 1e-15);

end

function testSpatialResampleGeometryAndPhotons(~)
%% oiSpatialResample changes sample pitch and preserves aligned samples.

oi = localTransformOI([6 8]);
basePhotons = oiGet(oi,'photons');
baseSpacing = oiGet(oi,'sample spacing');

dx = 2*baseSpacing(1);
resampled = oiSpatialResample(oi,dx,'m','linear');
resampledPhotons = oiGet(resampled,'photons');

expectedPhotons = basePhotons(1:2:5,1:2:7,:);

assert(isequal(oiGet(resampled,'size'),[3 4]));
assert(max(abs(resampledPhotons(:) - expectedPhotons(:))) < 1e-12);
assert(max(abs(oiGet(resampled,'sample spacing') - [dx dx])) < 1e-15);
assert(abs(oiGet(resampled,'fov') - oiGet(oi,'fov')) < 1e-12);
assert(strcmp(oiGet(resampled,'name'),'transform-test-linear'));

support = oiGet(resampled,'spatial support linear');
assert(abs((support.x(2) - support.x(1)) - dx) < 1e-15);
assert(abs((support.y(2) - support.y(1)) - dx) < 1e-15);

end

function testPadValueGeometryAndPadModes(~)
%% oiPadValue preserves pitch and applies deterministic pad values.

oi = localTransformOI([4 5]);
basePhotons = oiGet(oi,'photons');
baseSpacing = oiGet(oi,'sample spacing');
baseWidth = oiGet(oi,'width');
imageDistance = oiGet(oi,'optics image distance',1.2);
padSize = [1 2 0];

zeroPadded = oiPadValue(oi,padSize,'zero photons',1.2);
meanPadded = oiPadValue(oi,padSize,'mean photons',1.2);
borderPadded = oiPadValue(oi,padSize,'border photons',1.2);

zeroPhotons = oiGet(zeroPadded,'photons');
meanPhotons = oiGet(meanPadded,'photons');
borderPhotons = oiGet(borderPadded,'photons');

expectedSize = [4 5] + 2*padSize(1:2);
expectedFOV = 2*atand((baseWidth*(1 + 2*padSize(2)/5))/(2*imageDistance));

assert(isequal(oiGet(zeroPadded,'size'),expectedSize));
assert(abs(oiGet(zeroPadded,'fov') - expectedFOV) < 1e-12);
assert(max(abs(oiGet(zeroPadded,'sample spacing') - baseSpacing)) < 1e-15);

assert(max(abs(zeroPhotons(2:5,3:7,:) - basePhotons),[],'all') < 1e-12);
assert(zeroPhotons(1,1,1) == 0);
assert(abs(sum(zeroPhotons,'all') - sum(basePhotons,'all')) < 1e-12);

planeMeans = squeeze(mean(mean(basePhotons,1),2));
assert(abs(meanPhotons(1,1,1) - planeMeans(1)) < 1e-12);
assert(abs(meanPhotons(1,1,2) - planeMeans(2)) < 1e-12);

assert(abs(borderPhotons(1,1,1) - basePhotons(1,1,1)) < 1e-12);
assert(abs(borderPhotons(1,1,2) - basePhotons(1,1,2)) < 1e-12);

assert(max(abs(oiGet(meanPadded,'sample spacing') - baseSpacing)) < 1e-15);
assert(max(abs(oiGet(borderPadded,'sample spacing') - baseSpacing)) < 1e-15);

end

function oi = localTransformOI(sz)
%% Build a small deterministic OI with explicit photons and geometry.

oi = oiCreate;
oi = oiSet(oi,'name','transform-test');
oi = oiSet(oi,'wave',[500 600]);
oi = oiSet(oi,'size',sz);
photons = reshape(1:(prod(sz)*2),[sz 2]);
oi = oiSet(oi,'photons',photons);
oi = oiSet(oi,'fov',6);

end
