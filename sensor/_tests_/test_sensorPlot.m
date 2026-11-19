function tests = test_sensorPlot
 tests = functiontests(localfunctions);
end

function testReturnedData(testCase)
ieInit;
scene = sceneSet(sceneCreate,'fov',4);
oi = oiCompute(oiCreate,scene);
sensor = sensorSet(sensorCreate,'qmethod','10 bit');
sensor = sensorSet(sensor,'noise flag',0);
sensor = sensorCompute(sensor,oi);
% Fixed regression values: MATLAB R2025b, model code at 015b1309.
testCase.verifyEqual(mean(double(sensorGet(sensor,'volts')),'all'), ...
    0.177979053753769,'RelTol',1e-6);
testCase.verifyEqual(mean(double(sensorGet(sensor,'electrons')),'all'), ...
    1779.78929924242,'RelTol',1e-6);
testCase.verifyEqual(mean(double(sensorGet(sensor,'dv')),'all'), ...
    182.246054292929,'RelTol',1e-6);
% Tests run numerically; no handle inspection or visual comparison.
for kind = {'electrons hline','volts vline','volts hline','dv hline'}
    data = sensorPlot(sensor,kind{1},[20 20],'no fig',true);
    testCase.verifyNotEmpty(data.data);
    testCase.verifyTrue(all(cellfun(@(x) all(isfinite(x(:))),data.data)));
end
actual = sensorPlot(sensor,'sensor snr',[],'no fig',true);
[snr,volts] = sensorSNR(sensor);
testCase.verifyEqual(actual.snr,snr);
testCase.verifyEqual(actual.volts,volts);
actual = sensorPlot(sensor,'pixel snr',[],'no fig',true);
[snr,volts] = pixelSNR(sensor);
testCase.verifyEqual(actual.snr,snr);
testCase.verifyEqual(actual.volts,volts);
a = sensorPlot(sensor,'electrons hist',[15 15 45 45],'no fig',true);
b = sensorPlot(sensor,'electrons hist',a.roiLocs,'no fig',true);
testCase.verifyEqual(a,b);
cfa = sensorPlot(sensor,'cfa block',[],'no fig',true);
testCase.verifyEqual(size(cfa,3),3);
testCase.verifyGreaterThanOrEqual(cfa,0);
testCase.verifyLessThanOrEqual(cfa,1);
names = sensorGet(sensor,'filter names');
names{3} = 'oDefault';
other = sensorSet(sensor,'filter names',names);
otherCFA = sensorPlot(other,'cfa block',[],'no fig',true);
testCase.verifySize(otherCFA,size(cfa));
testCase.verifyNotEqual(otherCFA,cfa);
etendue = sensorPlot(sensor,'etendue',[],'no fig',true);
testCase.verifyTrue(all(isfinite(etendue.sensorEtendue(:))));
testCase.verifyGreaterThanOrEqual(etendue.sensorEtendue,0);
human = sensorCreate('human');
filters = sensorPlot(human,'color filters',[],'no fig',true);
testCase.verifyEqual(filters.y,sensorGet(human,'color filters'));
sensor = sensorSet(sensor,'exp time',[0.05 0.05]);
sensor = sensorCompute(sensor,oi);
a = sensorPlot(sensor,'electrons hline',[20 20],'capture',1,'no fig',true);
b = sensorPlot(sensor,'electrons hline',[20 20],'capture',2,'no fig',true);
testCase.verifyEqual(a,b);
end
