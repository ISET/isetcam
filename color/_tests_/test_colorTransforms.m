function tests = test_colorTransforms()
tests = functiontests(localfunctions);
end

function testImageSensorTransformMatchesTarget(~)
%% RGBW sensor transform fits the target color matching functions

sensor = sensorCreate('rgbw');
sensorQE = sensorGet(sensor,'spectral qe');
wave = sensorGet(sensor,'wave');
targetQE = ieReadSpectra('xyzQuanta',wave);

T = imageSensorTransform(sensorQE,targetQE,'',wave,'mcc');
predictedQE = sensorQE*T;

assert(isequal(size(T),[4 3]));
assert(sqrt(mean((predictedQE(:) - targetQE(:)).^2)) < 1e-18);

end

function testImageSensorTransformMatchesPseudoinverse(~)
%% Unilluminated MCC transform agrees with the direct pseudoinverse fit

sensor = sensorCreate('rgbw');
sensorQE = sensorGet(sensor,'spectral qe');
wave = sensorGet(sensor,'wave');
targetQE = ieReadSpectra('xyzQuanta',wave);

T = imageSensorTransform(sensorQE,targetQE,'',wave,'mcc');
expectedT = pinv(sensorQE)*targetQE;

assert(isequal(size(expectedT),[4 3]));
assert(max(abs(T(:) - expectedT(:))) < 1e-12);

end

function testIeColorTransformSceneFit(~)
%% Sensor-to-XYZ transform produces a stable color fit for a rendered scene

scene = sceneCreate;
scene = sceneSet(scene,'fov',5);
sceneXYZ = sceneGet(scene,'xyz');

oi = oiCreate('wvf');
oi = oiCompute(oi,scene,'crop',true,'pixel size',1.2e-6);

sensor = sensorCreate('rgbw');
[colorFilters,filterNames] = ieReadColorFilter(sensorGet(sensor,'wave'), ...
    'gaussianlBGRWwithIR');
sensor = sensorSet(sensor,'filter transmissivities',colorFilters);
sensor = sensorSet(sensor,'filter names',filterNames);
sensor = sensorSet(sensor,'match oi',oi);
sensor = sensorSet(sensor,'noise flag',0);
sensor = sensorCompute(sensor,oi);

ip = ipCreate;
ip = ipCompute(ip,sensor);

T = ieColorTransform(sensor,'XYZ','D65','mcc');
sensorData = ipGet(ip,'sensor data');
sensorXYZ = imageLinearTransform(sensorData,T);

sceneXYZ = ieScale(sceneXYZ,1);
sensorXYZ = ieScale(sensorXYZ,1);

assert(isequal(size(sensorXYZ),size(sceneXYZ)));
assert(all(isfinite(sensorXYZ(:))));

sensorXYZ = RGB2XWFormat(sensorXYZ);
sceneXYZ = RGB2XWFormat(sceneXYZ);

linearFit = sensorXYZ\sceneXYZ;
linearPrediction = sensorXYZ*linearFit;
assert(sqrt(mean((linearPrediction(:) - sceneXYZ(:)).^2)) < 0.1);

affineSensorXYZ = [sensorXYZ,ones(size(sensorXYZ,1),1)];
affineFit = affineSensorXYZ\sceneXYZ;
affinePrediction = affineSensorXYZ*affineFit;
assert(sqrt(mean((affinePrediction(:) - sceneXYZ(:)).^2)) < 0.1);

end
