function tests = test_sceneAccessors()
tests = functiontests(localfunctions);
end

function testDefaultSceneGeometry(~)
%% Focused checks for sceneCreate + sceneGet geometry/accessors

ieInit;

tolerance = 1e-8;

scene = sceneCreate;

sceneSize = sceneGet(scene,'size');
wave = sceneGet(scene,'wave');
width = sceneGet(scene,'width');
height = sceneGet(scene,'height');
spatialResolution = sceneGet(scene,'spatial resolution');

assert(isequal(sceneGet(scene,'type'),'scene'))
assert(isequal(sceneSize,[64 96]))
assert(isequal(wave',(400:10:700)))
assert(abs(sceneGet(scene,'mean luminance') - 100) < 1e-6)
assert(abs(width / sceneSize(2) - spatialResolution(2)) < tolerance)
assert(abs(height / sceneSize(1) - spatialResolution(1)) < tolerance)

end

function testSceneSetBookkeepingAndData(~)
%% Focused checks for sceneSet on bookkeeping, geometry, photons, and energy

ieInit;

scene = sceneCreate('empty');
wave = (500:10:600)';
photons = reshape(1:(4*5*numel(wave)), [4 5 numel(wave)]);
metadata = struct('source','unit-test','version',1);

scene = sceneSet(scene,'wave',wave);
scene = sceneSet(scene,'name','accessor test scene');
scene = sceneSet(scene,'metadata',metadata);
scene = sceneSet(scene,'distance',3.5);
scene = sceneSet(scene,'fov',12);
scene = sceneSet(scene,'photons',photons);
scenePhotons = sceneGet(scene,'photons');

assert(strcmp(sceneGet(scene,'name'),'accessor test scene'))
assert(isequal(sceneGet(scene,'metadata'),metadata))
assert(sceneGet(scene,'distance') == 3.5)
assert(sceneGet(scene,'fov') == 12)
assert(isequal(sceneGet(scene,'size'),[4 5]))
assert(isequal(sceneGet(scene,'wave'),wave))
assert(max(abs(scenePhotons(:) - photons(:))) < 1e-6)

energy = sceneGet(scene,'energy');

sceneFromEnergy = sceneCreate('empty');
sceneFromEnergy = sceneSet(sceneFromEnergy,'wave',wave);
sceneFromEnergy = sceneSet(sceneFromEnergy,'energy',energy);
sceneFromEnergyPhotons = sceneGet(sceneFromEnergy,'photons');

assert(max(abs(sceneFromEnergyPhotons(:) - scenePhotons(:))) / max(abs(scenePhotons(:))) < 1e-6)

end