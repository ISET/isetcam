function tests = test_ipData()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% Show the ip data representations
%
% The input data 

%%
ieInit;

%% Data

scene = sceneCreate; scene = sceneSet(scene,'fov',4);

oi = oiCreate; oi = oiCompute(oi,scene);

sensor = sensorCreate; sensor = sensorCompute(sensor,oi);

ip = ipCreate; ip = ipCompute(ip,sensor);
% ipWindow(ip);

%%  Read the main data types in sequence

input = ipGet(ip,'input');
sensorSpace = ipGet(ip,'sensor space');
dataICS = ipGet(ip,'data ics');
dataICSCorrected = ipGet(ip,'data ics illuminant corrected');
dataDisplay = ipGet(ip,'data display');
dataSRGB = ipGet(ip,'data srgb');

inputSize = size(input);
assert(isequal(ipGet(ip,'input size'),inputSize));
assert(isequal(size(sensorSpace),[inputSize 3]));
assert(isequal(size(dataICS),[inputSize 3]));
assert(isequal(size(dataICSCorrected),[inputSize 3]));
assert(isequal(size(dataDisplay),[inputSize 3]));
assert(isequal(size(dataSRGB),[inputSize 3]));

assert(abs(mean(double(dataDisplay(:)))/0.256176269958385 - 1) < 1e-6);
assert(abs(mean(double(dataSRGB(:)))/0.499497101490208 - 1) < 1e-6);
assert(min(dataDisplay(:)) >= 0);
assert(max(dataDisplay(:)) <= 1);
assert(min(dataSRGB(:)) >= 0);
assert(max(dataSRGB(:)) <= 1);

%%




end
