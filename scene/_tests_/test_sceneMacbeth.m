function tests = test_sceneMacbeth()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% v_sceneMacbeth
%
% Validate Macbeth chart scene creation
%
% Copyright Imageval, LLC, 2014

%%
ieInit

fprintf('Validating macbeth scenes ...')

%% Default and empty
patchSize = 32; wave = 500:5:600;
scene = sceneCreate('default',patchSize,wave);
% ieAddObject(scene); sceneWindow;
assert(isequal(scene.spectrum.wave,500:5:600),'Bad default scene create');

scene = sceneCreate('empty',[],400:2:700);
assert(isequal(scene.spectrum.wave,400:2:700),'Bad empty scene create');

%% Macbeth cases

scene = sceneCreate('macbeth d65');
tmp = sceneGet(scene,'photons');
assert(sum(tmp(:))/7.1660e+20 - 1 < 1e-5);

scene = sceneCreate('macbeth d50');
tmp = sceneGet(scene,'photons');
assert(sum(tmp(:))/7.3033e+20 - 1 < 1e-5);

scene = sceneCreate('macbeth c');
tmp = sceneGet(scene,'photons');
assert(sum(tmp(:))/7.3973e+20 - 1 < 1e-5);

scene = sceneCreate('macbeth tungsten');
tmp = sceneGet(scene,'photons');
assert(sum(tmp(:))/8.2817e+20 - 1 < 1e-5);

scene = sceneCreate('macbeth fluorescent');
tmp = sceneGet(scene,'photons');
assert(sum(tmp(:))/4.7760e+20 - 1 < 1e-5);

wave = 390:900;
scene = sceneCreate('macbeth equal energy infrared',[],wave);
assert(isequal(scene.spectrum.wave,390:900),'Bad IR scene create');

fprintf('done\n');

%% END
end
