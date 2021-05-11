%% v_sceneMacbeth
%
% Validate Macbeth chart scene creation
%
% Copyright Imageval, LLC, 2014

%%
ieInit

%% Default and empty
patchSize = 32;
wave = 500:5:600;
scene = sceneCreate('default', patchSize, wave);
ieAddObject(scene);
sceneWindow;
assert(isequal(scene.spectrum.wave, 500:5:600), 'Bad default scene create');

scene = sceneCreate('empty', [], 400:2:700);
assert(isequal(scene.spectrum.wave, 400:2:700), 'Bad empty scene create');

%% Macbeth cases
scene = sceneCreate('macbeth d65');
ieAddObject(scene);
sceneWindow;

scene = sceneCreate('macbeth d50');
ieAddObject(scene);
sceneWindow;

scene = sceneCreate('macbeth c');
ieAddObject(scene);
sceneWindow;

scene = sceneCreate('macbeth tungsten');
ieAddObject(scene);
sceneWindow;

scene = sceneCreate('macbeth fluorescent');
ieAddObject(scene);
sceneWindow;

%% IR case
wave = 390:900;
scene = sceneCreate('macbeth equal energy infrared', [], wave);
ieAddObject(scene);
sceneWindow;
assert(isequal(scene.spectrum.wave, 390:900), 'Bad IR scene create');
