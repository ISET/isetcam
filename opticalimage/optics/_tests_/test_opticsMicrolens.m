function tests = test_opticsMicrolens()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% v_microlens - validate microlens calls
%
% Test the main microlens related routines.
%
% Copyright Imageval Consulting, LLC 2015


%% Each section starts with a fresh copy of the sensor/oi/mlens
ieInit

%%
oi = oiCreate; ieAddObject(oi);
sensor = sensorCreate;
sensor = sensorSet(sensor,'fov',30,oi);
ieAddObject(sensor);

%% Try gets and sets

mlens = mlensCreate;

mlensGet(mlens,'name');
mlensGet(mlens,'type');

assert(mlensGet(mlens,'source fnumber')==4);

mlensGet(mlens,'source diameter','meters');
assert(abs(mlensGet(mlens,'source diameter','microns')- 965.6888) < 1e-4);

assert(abs(mlensGet(mlens,'ml fnumber')-2.5) < 1e-4);
mlensGet(mlens,'ml diameter','meters');
assert(abs(mlensGet(mlens,'ml diameter','microns')-2.8) < 1e-4);

mlensGet(mlens,'source fnumber');
mlensGet(mlens,'chief ray angle');

mlens = mlensSet(mlens,'chief ray angle',10);
mlensGet(mlens,'chief ray angle');

%% Radiance estimates

mlens = mlensCreate;

% Computes the irradiance and various other quantities, storing them in the
% mlens structure itself.
[mlens, psImages] = mlRadiance(mlens);

% Check irradiance and phase-space arrays numerically.
sIrradiance = mlensGet(mlens,'source irradiance');
pIrradiance = mlensGet(mlens,'pixel irradiance');
% Fixed regression values: MATLAB R2025b, model code at 015b1309.
testCase.verifyEqual(sum(sIrradiance,'all'),1953,'AbsTol',1e-10);
testCase.verifyEqual(sum(pIrradiance,'all'),595.97015625,'RelTol',1e-8);
testCase.verifyTrue(all(isfinite(sIrradiance(:))));
testCase.verifyGreaterThanOrEqual(sIrradiance,0);
testCase.verifyGreaterThan(sum(pIrradiance,'all'),0);
for name = {'source','lens','lensOffset','detector'}
    values = psImages.(name{1});
    testCase.verifyTrue(all(isfinite(values(:))));
    testCase.verifyGreaterThanOrEqual(values,0);
end

%% Etendue

sensor = ieGetObject('sensor');
sensor = mlAnalyzeArrayEtendue(sensor,'no microlens');
etendue = sensorGet(sensor,'etendue');
testCase.verifySize(etendue,sensorGet(sensor,'size'));
testCase.verifyTrue(all(isfinite(etendue(:))));
testCase.verifyGreaterThanOrEqual(etendue,0);

sensor = mlAnalyzeArrayEtendue(sensor,'centered');
etendue = sensorGet(sensor,'etendue');
testCase.verifySize(etendue,sensorGet(sensor,'size'));
testCase.verifyTrue(all(isfinite(etendue(:))));
testCase.verifyGreaterThanOrEqual(etendue,0);

sensor = mlAnalyzeArrayEtendue(sensor,'optimal');
etendue = sensorGet(sensor,'etendue');
testCase.verifySize(etendue,sensorGet(sensor,'size'));
testCase.verifyTrue(all(isfinite(etendue(:))));
testCase.verifyGreaterThanOrEqual(etendue,0);

%% END
end
