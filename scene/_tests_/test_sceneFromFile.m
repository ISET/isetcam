function tests = test_sceneFromFile()
tests = functiontests(localfunctions);
end

function testMain(~)
%% Validation script for sceneFromFile
%
% Makes and deletes a small test scene in the local directory
%
% BW

%%
ieInit;

% Use the local directory that is not included in the git repository.
cd(fullfile(isetRootPath,'local'));

%% Create and read a scene variable from the file

% This is the new feature
scene = sceneCreate;
save('testS','scene');

s = sceneFromFile('testS');
assert(isequal(s,scene));  % Should be the same

%%  Read in a mat multispectral file

% Check that the old stuff worked
fName = 'StuffedAnimals_tungsten-hdrs.mat';
scene = sceneFromFile(fName,'multispectral');
mn = sceneGet(scene,'mean luminance');
assert(abs(mn - 30.04707249) < 1e-5);

%% Create a file from RGB data
rng(1);
RGB = ieClip(255*rand(10,10,3),0,255);
scene = sceneFromFile(RGB,'rgb',100,'lcdExample');
sceneWindow(scene);

%% Now try sceneToFile with the scene data

% This tests whether the new 'fov' and 'dist' read/write works
sceneToFile('testS2',scene);
scene2 = sceneFromFile('testS2','multispectral');

wave1 = sceneGet(scene,'wave');
wave2 = sceneGet(scene2,'wave');
q1 = sceneGet(scene,'photons',wave1(10));
q2 = sceneGet(scene2,'photons',wave2(10));
ill1 = sceneGet(scene,'illuminant photons');
ill2 = sceneGet(scene2,'illuminant photons');
photons1 = sceneGet(scene,'photons');
photons2 = sceneGet(scene2,'photons');
spectrum1 = sceneGet(scene,'spectrum');
spectrum2 = sceneGet(scene2,'spectrum');
data1 = sceneGet(scene,'data');
data2 = sceneGet(scene2,'data');

assert(isequal(wave1,wave2))
assert(strcmp(sceneGet(scene,'type'), sceneGet(scene2,'type')))
assert(isequal(sceneGet(scene,'magnification'), sceneGet(scene2,'magnification')))
assert(sceneGet(scene,'fov') == sceneGet(scene2,'fov'))
assert(sceneGet(scene,'distance') == sceneGet(scene2,'distance'))
assert(isequal(spectrum1.wave, spectrum2.wave))
assert(max(abs(q1(:) - q2(:))) < 1e-5)
assert(abs(mean(photons1(:)) - mean(photons2(:))) < 1e-8)
assert(max(abs(ill1(:) - ill2(:))) / max(abs(ill1(:))) < 1e-6)
assert(isequal(fieldnames(data1), fieldnames(data2)))
assert(max(abs(data1.photons(:) - data2.photons(:))) < 1e-5)
if isfield(data1,'luminance') && isfield(data2,'luminance')
    assert(isempty(data1.luminance) == isempty(data2.luminance))
    if ~isempty(data1.luminance)
        assert(max(abs(data1.luminance(:) - data2.luminance(:))) < 1e-5)
    end
end
assert(strcmp(sceneGet(scene2,'name'),'testS2'))

% ieNewGraphWin; title('Validating sceneToFile');
% assert( max(abs(q1(1:10:end)-q2(1:10:end))) < 1e-5);
% plot(q1(1:10:end),q2(1:10:end),'.');
% grid on; xlabel('scene 1'); ylabel('scene 2');

%% Now try on a jpg image
fullFileName = which('eagle.jpg');
scene = sceneFromFile(fullFileName,'rgb',100,'lcdExample');
assert(abs(sceneGet(scene,'fov') - 15.5233) < 1e-3);

% sceneWindow(scene);

%% Clean up
if exist('testS.mat','file'), delete('testS.mat'); end
if exist('testS2.mat','file'), delete('testS2.mat'); end

%%

end
