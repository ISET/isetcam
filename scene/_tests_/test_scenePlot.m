function tests = test_scenePlot
 tests = functiontests(localfunctions);
end

function testReturnedData(testCase)
ieInit;
scene = sceneCreate;
row = round(sceneGet(scene,'rows')/2);
photons = sceneGet(scene,'photons');
data = scenePlot(scene,'hline radiance',[1 row],'nofigure');
testCase.verifyEqual(data.data,squeeze(photons(row,:,:))');
data = scenePlot(scene,'luminance hline',[1 row],'nofigure');
luminance = sceneGet(scene,'luminance');
testCase.verifyEqual(data.data,luminance(row,:)');
data = scenePlot(scene,'luminance fft hline',[1 row],'nofigure');
testCase.verifyEqual(max(data.data),1,'AbsTol',1e-12);
testCase.verifyEqual(numel(data.freq),sceneGet(scene,'cols')/2);
data = scenePlot(scene,'radiance image with grid',[],21,'nofigure');
testCase.verifyEqual(data.rad,photons);
for rect = {[26 40 13 16],[6 51 8 12]}
    data = scenePlot(scene,'reflectance roi',rect{1},'nofigure');
    testCase.verifyTrue(all(isfinite(data.reflectance(:))));
    testCase.verifyGreaterThanOrEqual(data.reflectance,0);
    testCase.verifyLessThanOrEqual(data.reflectance,1.01);
    xy = scenePlot(scene,'chromaticity',rect{1},'nofigure');
    testCase.verifyGreaterThanOrEqual(xy.x,0);
    testCase.verifyLessThanOrEqual(xy.x+xy.y,1);
end
data = scenePlot(scene,'illuminant photons',[],'nofigure');
testCase.verifyEqual(double(mean(data.photons)),1.4089583e16,'RelTol',1e-6);
depth = scenePlot(scene,'depth map',[],'nofigure');
testCase.verifyEqual(depth,sceneGet(scene,'depth map'));
end
