function tests = test_displayAccessors()
tests = functiontests(localfunctions);
end

function testDefaultDisplayStructure(~)
%% Default display has internally consistent spectral and LUT fields

d = displayCreate('default');

assert(strcmp(displayGet(d,'type'),'display'));
assert(strcmp(displayGet(d,'name'),'default'));
assert(displayGet(d,'is emissive') == true);

wave = displayGet(d,'wave');
spd = displayGet(d,'spd');
gammaTable = displayGet(d,'gamma table');

assert(isequal(wave,(400:10:700)'));
assert(isequal(size(spd),[numel(wave) 3]));
assert(isequal(size(gammaTable),[256 3]));
assert(displayGet(d,'bits') == 8);
assert(displayGet(d,'nlevels') == 256);
assert(displayGet(d,'n primaries') == 3);
assert(displayGet(d,'binwidth') == 10);

assert(max(abs(gammaTable(:,1) - linspace(0,1,256)')) < 1e-12);
assert(isequal(gammaTable(:,1),gammaTable(:,2)));
assert(isequal(gammaTable(:,1),gammaTable(:,3)));
assert(max(abs(displayGet(d,'white spd') - sum(spd,2))) < 1e-15);

end

function testCalibratedDisplayModelLoads(~)
%% Calibrated display models can be discovered and loaded by name or path

displayFiles = displayList('show',false);
displayNames = {displayFiles.name};
assert(any(strcmp(displayNames,'LCD-Apple.mat')));

d = displayCreate('LCD-Apple');

assert(strcmp(displayGet(d,'type'),'display'));
assert(strcmp(displayGet(d,'name'),'LCD-Apple'));
assert(displayGet(d,'bits') == 10);
assert(displayGet(d,'nlevels') == 1024);
assert(displayGet(d,'n primaries') == 3);

wave = displayGet(d,'wave');
spd = displayGet(d,'spd');
gammaTable = displayGet(d,'gamma table');

assert(isequal(size(wave),[101 1]));
assert(isequal(size(spd),[101 3]));
assert(isequal(size(gammaTable),[1024 3]));
assert(all(isfinite(spd(:))));
assert(all(spd(:) >= 0));
assert(all(gammaTable(:) >= 0));
assert(all(gammaTable(:) <= 1));

rgb2xyz = displayGet(d,'rgb2xyz');
whiteXYZ = displayGet(d,'white xyz');
assert(isequal(size(rgb2xyz),[3 3]));
assert(max(abs([1 1 1]*rgb2xyz - whiteXYZ)) < 1e-10);
assert(abs(displayGet(d,'peak luminance') - whiteXYZ(2)) < 1e-10);
assert(displayGet(d,'dark luminance') == 0);

modelPath = fullfile(isetRootPath,'data','displays','LCD-Apple.mat');
pathLoadedDisplay = displayCreate(modelPath);
assert(strcmp(displayGet(pathLoadedDisplay,'name'),'LCD-Apple'));
assert(isequal(displayGet(pathLoadedDisplay,'wave'),wave));
assert(isequal(displayGet(pathLoadedDisplay,'gamma table'),gammaTable));

end

function testDisplaySettersRoundTrip(~)
%% Basic display setters preserve spatial and image metadata

d = displayCreate('default');

d = displaySet(d,'dpi',110);
d = displaySet(d,'viewing distance',0.75);
d = displaySet(d,'size',[0.6 0.34]);
d = displaySet(d,'refresh rate',120);
d = displaySet(d,'image',reshape(linspace(0,1,18),[2 3 3]));

assert(displayGet(d,'dpi') == 110);
assert(abs(displayGet(d,'meters per dot') - 0.0254/110) < 1e-15);
assert(displayGet(d,'dots per meter') == 1/displayGet(d,'meters per dot'));
assert(displayGet(d,'viewing distance') == 0.75);
assert(isequal(displayGet(d,'size'),[0.6 0.34]));
assert(displayGet(d,'refresh rate') == 120);
assert(isequal(size(displayGet(d,'image')),[2 3 3]));

end

function testWaveSetterInterpolatesSpectralData(~)
%% Changing wavelength sampling interpolates SPD and ambient data together

d = displayCreate('LCD-Apple');
originalWave = displayGet(d,'wave');
newWave = originalWave(1:5:end);

d = displaySet(d,'ambient spd',ones(displayGet(d,'nwave'),1)*0.01);
d = displaySet(d,'wave',newWave);

assert(isequal(displayGet(d,'wave'),newWave));
assert(isequal(size(displayGet(d,'spd')),[numel(newWave) 3]));
assert(isequal(size(displayGet(d,'ambient spd')),[numel(newWave) 1]));
assert(all(isfinite(displayGet(d,'spd')), 'all'));
assert(all(displayGet(d,'ambient spd') >= 0));

end
