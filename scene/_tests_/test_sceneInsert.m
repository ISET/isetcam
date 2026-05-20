function tests = test_sceneInsert()
tests = functiontests(localfunctions);
end

function testInsertPreservesBaseGeometryAndReplacesRegion(~)

ieInit;

baseScene = sceneCreate('uniformee',64);
insertScene = sceneCreate('checkerboard',8,4,'ep');
insertScene = sceneSet(insertScene,'resize',[16 16]);
position = [9 17];

basePhotons = sceneGet(baseScene,'photons');
insertPhotons = sceneGet(insertScene,'photons');
baseSupport = sceneGet(baseScene,'spatial support');

insertedScene = sceneInsert(baseScene,insertScene,position);

assert(isequal(sceneGet(insertedScene,'size'),sceneGet(baseScene,'size')), ...
    'sceneInsert changed the base scene size');
assertRelativeError(sceneGet(insertedScene,'fov'),sceneGet(baseScene,'fov'),1e-12, ...
    'sceneInsert changed the base scene FOV');
assertRelativeError(sceneGet(insertedScene,'width'),sceneGet(baseScene,'width'),1e-12, ...
    'sceneInsert changed the base scene width');
assertRelativeError(sceneGet(insertedScene,'height'),sceneGet(baseScene,'height'),1e-12, ...
    'sceneInsert changed the base scene height');

insertedSupport = sceneGet(insertedScene,'spatial support');
assert(max(abs(insertedSupport(:) - baseSupport(:))) < 1e-12, ...
    'sceneInsert changed the base scene spatial support');

rows = (1:16) + (position(1) - 1);
cols = (1:16) + (position(2) - 1);
insertedPhotons = sceneGet(insertedScene,'photons');

patchRelativeError = max(abs(insertedPhotons(rows,cols,:) - insertPhotons),[],'all') ...
    / max(abs(insertPhotons(:)));
assert(patchRelativeError < 1e-12, ...
    'sceneInsert did not copy the inserted photon region correctly');

outsideMask = true(size(basePhotons));
outsideMask(rows,cols,:) = false;
outsideDifference = max(abs(insertedPhotons(outsideMask) - basePhotons(outsideMask)));
assert(outsideDifference == 0, ...
    'sceneInsert changed photons outside the inserted region');

end

function assertRelativeError(actual,expected,tolerance,message)

relativeError = abs(actual - expected)/max(abs(expected),eps);
assert(relativeError < tolerance,message);

end