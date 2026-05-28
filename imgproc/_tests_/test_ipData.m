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

assert(isequal(size(input),[72 88]));
assert(isequal(size(sensorSpace),[72 88 3]));
assert(isequal(size(dataICS),[72 88 3]));
assert(isequal(size(dataICSCorrected),[72 88 3]));
assert(isequal(size(dataDisplay),[72 88 3]));
assert(isequal(size(dataSRGB),[72 88 3]));

assert(abs(mean(double(input(:)))/0.176879730209539 - 1) < 1e-6);
assert(abs(mean(double(dataDisplay(:)))/0.256176269958385 - 1) < 1e-6);
assert(abs(mean(double(dataSRGB(:)))/0.499497101490208 - 1) < 1e-6);
assert(min(dataDisplay(:)) >= 0);
assert(max(dataDisplay(:)) <= 1);
assert(min(dataSRGB(:)) >= 0);
assert(max(dataSRGB(:)) <= 1);

%%




end
