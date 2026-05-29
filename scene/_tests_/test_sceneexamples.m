function tests = test_sceneexamples()
tests = functiontests(localfunctions);
end

function testMain(~)
%% Show examples of built-in scenes
%
% ISET includes many *built-in scenes* that are used for testing
% the properties of *optics* and *sensors*.  This script shows
% how to create those scenes.
%
% Many of built-in scenes can be created using parameters that
% are set when you call the *sceneCreate* function.  This script
% illustrates how to set thses parameters.  You can learn how to
% create these scenes by using
%
%   doc('sceneCreate')
%
% See also:  s_sceneDemo, sceneCreate, s_sceneFromMultispectral,
%            s_sceneFromRGB
%
% Copyright ImagEval Consultants, LLC, 2003.

%%
ieInit;

fprintf('Validating geometry-aware scene examples ... ');

%% Harmonic
parms.freq = 1; parms.contrast = 1; parms.ph = 0;
parms.ang = 0; parms.row = 64; parms.col = 64; parms.GaborFlag = 0;
[scene,~] = sceneCreate('harmonic',parms);
lum = sceneGet(scene,'luminance');
rowProfile = lum(round(size(lum,1)/2),:);
spectrum = abs(fft(rowProfile - mean(rowProfile)));
[~,dominantIndex] = max(spectrum(2:floor(numel(spectrum)/2)));
assert(dominantIndex + 1 == 2,'Unexpected harmonic dominant spatial frequency');
assertRelativeError(mean(rowProfile),100,1e-6,'Unexpected harmonic mean luminance');
assertRelativeError(std(rowProfile),71.2697,1e-4,'Unexpected harmonic row-profile contrast');

%% Checkerboard
scene = sceneCreate('checkerboard',16,8,'ep');
lum = sceneGet(scene,'luminance');
midRow = lum(round(size(lum,1)/2),:);
stateTransitions = sum(abs(diff(midRow > 100)) > 0);
assert(stateTransitions == 15,'Unexpected checkerboard transition count');
assert(min(lum(:)) < 1e-3,'Unexpected checkerboard dark-square luminance');
assertRelativeError(max(lum(:)),199.9998,1e-5,'Unexpected checkerboard bright-square luminance');

%% Grid lines
scene = sceneCreate('grid lines',128,16);
lum = sceneGet(scene,'luminance');
rowProfile = lum(round(size(lum,1)/2),:);
colProfile = lum(:,round(size(lum,2)/2));
threshold = (max(rowProfile) + min(rowProfile))/2;
assert(sum(diff([0,rowProfile > threshold,0]) == 1) == 8,'Unexpected horizontal grid-line count');
assert(sum(diff([0;colProfile > threshold;0]) == 1) == 8,'Unexpected vertical grid-line count');
assertRelativeError(mean(rowProfile),51.6169,1e-4,'Unexpected grid-line row mean luminance');

%% Point array
scene = sceneCreate('point array',256,32);
lum = sceneGet(scene,'luminance');
brightMask = lum > max(lum(:))/2;
expectedPointLocations = 16:32:240;
assert(nnz(brightMask) == 64,'Unexpected bright-point count');
assert(isequal(find(sum(brightMask,2) > 0)',expectedPointLocations), ...
    'Unexpected bright-point row locations');
assert(isequal(find(sum(brightMask,1) > 0),expectedPointLocations), ...
    'Unexpected bright-point column locations');

%% Slanted bar
scene = sceneCreate('slantedBar',128,1.3);
lum = sceneGet(scene,'luminance');
[~,topEdge] = max(abs(diff(lum(10,:))));
[~,midEdge] = max(abs(diff(lum(round(size(lum,1)/2),:))));
[~,bottomEdge] = max(abs(diff(lum(size(lum,1)-9,:))));
assert(isequal([topEdge, midEdge, bottomEdge],[22 64 107]), ...
    'Unexpected slanted-edge locations');

%% Spectral and intensity scenes
scene = sceneCreate('lined65',[128 128]);
assert(isequal(sceneGet(scene,'size'),[128 128]),'Unexpected line scene size');
assertRelativeError(mean(sceneGet(scene,'photons'),'all'),3.5944160141e+15,1e-5, ...
    'Unexpected line scene mean photons');

scene = sceneCreate('macbeth tungsten',16,380:5:720);
assertRelativeError(mean(sceneGet(scene,'photons'),'all'),4.5392528313e+15,1e-5, ...
    'Unexpected macbeth tungsten mean photons');

% Use the deterministic default reflectance-chart parameters from chartParams.
chartP = chartParams;
scene = sceneCreate('reflectance chart',chartP);
assertRelativeError(mean(sceneGet(scene,'photons'),'all'),3.8619779549e+15,1e-5, ...
    'Unexpected reflectance-chart mean photons');

scene = sceneCreate('uniformEESpecify',128,380:10:720);
lum = sceneGet(scene,'luminance');
assertRelativeError(mean(lum,'all'),100,1e-6,'Unexpected uniform-field mean luminance');
assert(max(abs(lum(:) - lum(1,1))) < 1e-6,'Uniform field is not spatially constant');

scene = sceneCreate('lstar',[80 10],20,1);
lum = sceneGet(scene,'luminance');
assert(isequal(size(lum),[80 200]),'Unexpected L* target size');
assertRelativeError(mean(lum,'all'),100,1e-6,'Unexpected L* target mean luminance');

scene = sceneCreate('exponential intensity ramp',256,1024);
lum = sceneGet(scene,'luminance');
colMeans = mean(lum,1);
assert(all(diff(colMeans) >= -1e-6),'Exponential ramp is not monotonic across columns');
assertRelativeError(colMeans(end)/colMeans(1),1024,1e-6, ...
    'Unexpected exponential-ramp dynamic range');

fprintf('done\n');
%% END

end

function assertRelativeError(actual,expected,tolerance,message)

relativeError = abs(actual - expected)/max(abs(expected),eps);
assert(relativeError < tolerance,message);

end
