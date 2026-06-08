function tests = test_sceneMacbeth()
tests = functiontests(localfunctions);
end

function testMain(~)
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
assert(isequal(sceneGet(scene,'wave')',500:5:600),'Bad default scene create');

scene = sceneCreate('empty',[],400:2:700);
assert(isequal(sceneGet(scene,'wave')',400:2:700),'Bad empty scene create');

%% Macbeth cases

scene = sceneCreate('macbeth d65');
tmp = sceneGet(scene,'photons');
assert(sum(tmp(:))/7.1660e+20 - 1 < 1e-5);
verifyPatchMetrics(scene, ...
    [40.9492492676 28.1027641296 319.6743164062 15.9549722672], ...
    [1.7953888057e+15 1.7652398802e+15 1.1276067268e+16 5.8089969549e+14]);

scene = sceneCreate('macbeth d50');
tmp = sceneGet(scene,'photons');
assert(sum(tmp(:))/7.3033e+20 - 1 < 1e-5);

scene = sceneCreate('macbeth c');
tmp = sceneGet(scene,'photons');
assert(sum(tmp(:))/7.3973e+20 - 1 < 1e-5);

scene = sceneCreate('macbeth tungsten');
tmp = sceneGet(scene,'photons');
assert(sum(tmp(:))/8.2817e+20 - 1 < 1e-5);
verifyPatchMetrics(scene, ...
    [44.1102066040 28.4767818451 313.5773010254 15.6320362091], ...
    [2.4605373718e+15 2.1261567195e+15 1.2143839641e+16 6.2493035803e+14]);

scene = sceneCreate('macbeth fluorescent');
tmp = sceneGet(scene,'photons');
assert(sum(tmp(:))/4.7760e+20 - 1 < 1e-5);

wave = 390:900;
scene = sceneCreate('macbeth equal energy infrared',[],wave);
assert(isequal(sceneGet(scene,'wave')',390:900),'Bad IR scene create');

fprintf('done\n');

%% END
end

function verifyPatchMetrics(scene,expectedLuminance,expectedMeanPhotons)

sceneSize = sceneGet(scene,'size');
patchHeight = sceneSize(1)/4;
patchWidth = sceneSize(2)/6;

patchGrid = [1 1; 2 4; 4 1; 4 6];

for ii = 1:size(patchGrid,1)
    patchRow = patchGrid(ii,1);
    patchCol = patchGrid(ii,2);
    rect = [(patchCol - 1)*patchWidth + 1, (patchRow - 1)*patchHeight + 1, ...
        patchWidth - 1, patchHeight - 1];
    meanLuminance = sceneGet(scene,'roi mean luminance',rect);
    meanPhotons = mean(sceneGet(scene,'roi mean photons',rect),'all');
    assertRelativeError(meanLuminance,expectedLuminance(ii),1e-5, ...
        'Unexpected Macbeth patch luminance');
    assertRelativeError(meanPhotons,expectedMeanPhotons(ii),1e-5, ...
        'Unexpected Macbeth patch mean photons');
end

end

function assertRelativeError(actual,expected,tolerance,message)

relativeError = abs(actual - expected)/max(abs(expected),eps);
assert(relativeError < tolerance,message);

end
