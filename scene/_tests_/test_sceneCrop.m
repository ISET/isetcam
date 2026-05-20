function tests = test_sceneCrop()
tests = functiontests(localfunctions);
end

function testCropPreservesCropPhotometryAndGeometry(~)

ieInit;

scene = sceneCreate('harmonic',harmonicP('row',64,'col',96,'freq',3, ...
    'phase',0,'gaborflag',0));

metadata.coordinates = [1 2 3];
metadata.label = 'keep me';
scene = sceneSet(scene,'metadata',metadata);

rect = [10 20 15 7];
originalFOV = sceneGet(scene,'fov');
originalWidth = sceneGet(scene,'width');
originalPhotons = sceneGet(scene,'photons');
roiMeanPhotons = sceneGet(scene,'roi mean photons',rect);

[cropped, returnedRect] = sceneCrop(scene,rect);

assert(isequal(returnedRect,rect),'sceneCrop returned an unexpected rect');
assert(isequal(sceneGet(cropped,'size'),[8 16]),'sceneCrop returned an unexpected size');

% sceneCrop currently preserves horizontal FOV and width, then derives the
% cropped sampling and support from the new number of rows and columns.
assertRelativeError(sceneGet(cropped,'fov'),originalFOV,1e-12, ...
    'sceneCrop unexpectedly changed the horizontal FOV');
assertRelativeError(sceneGet(cropped,'width'),originalWidth,1e-12, ...
    'sceneCrop unexpectedly changed the scene width');

croppedMeanPhotons = sceneGet(cropped,'mean photons spd');
assert(max(abs(croppedMeanPhotons(:)./roiMeanPhotons(:) - 1)) < 1e-6, ...
    'sceneCrop did not preserve ROI mean photon values');

expectedPhotons = originalPhotons(rect(2):(rect(2)+rect(4)), ...
    rect(1):(rect(1)+rect(3)), :);
assertRelativeError(mean(sceneGet(cropped,'photons'),'all'), ...
    mean(expectedPhotons,'all'),1e-6, ...
    'sceneCrop changed the cropped mean photon level');

spatialSupport = sceneGet(cropped,'spatial support');
sampleSpacing = sceneGet(cropped,'sample spacing');
croppedWidth = sceneGet(cropped,'width');
croppedHeight = sceneGet(cropped,'height');

expectedX = [-croppedWidth/2 + sampleSpacing(2)/2, croppedWidth/2 - sampleSpacing(2)/2];
expectedY = [-croppedHeight/2 + sampleSpacing(1)/2, croppedHeight/2 - sampleSpacing(1)/2];

assertRelativeError(spatialSupport(1,1,1),expectedX(1),1e-12, ...
    'sceneCrop returned an unexpected left spatial-support edge');
assertRelativeError(spatialSupport(1,end,1),expectedX(2),1e-12, ...
    'sceneCrop returned an unexpected right spatial-support edge');
assertRelativeError(spatialSupport(1,1,2),expectedY(1),1e-12, ...
    'sceneCrop returned an unexpected top spatial-support edge');
assertRelativeError(spatialSupport(end,1,2),expectedY(2),1e-12, ...
    'sceneCrop returned an unexpected bottom spatial-support edge');

croppedMetadata = sceneGet(cropped,'metadata');
assert(isequal(croppedMetadata.rect,rect),'sceneCrop did not store the crop rect in metadata');
assert(~isfield(croppedMetadata,'coordinates'), ...
    'sceneCrop did not clear stale metadata coordinates');
assert(strcmp(croppedMetadata.label,'keep me'), ...
    'sceneCrop unexpectedly removed unrelated metadata');

end

function assertRelativeError(actual,expected,tolerance,message)

relativeError = abs(actual - expected)/max(abs(expected),eps);
assert(relativeError < tolerance,message);

end