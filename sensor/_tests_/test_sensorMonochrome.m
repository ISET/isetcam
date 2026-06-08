function tests = test_sensorMonochrome()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% v_sensorMonochrome
%
% Test whether we can build and show data from a monochrome sensor
%
% Copyright Imageval Consulting, LLC 2015

%%
ieInit

%% Build on oi
s = sceneCreate; 
oi = oiCreate; oi = oiCompute(oi,s);

%% Monochrome sensor response
sensor = sensorCreate('monochrome');
sensor = sensorSet(sensor,'noise flag',0);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

volts = sensorGet(sensor,'volts');
electrons = sensorGet(sensor,'electrons');
assert( abs(mean(volts,'all')/0.327242314815521 - 1) < 1e-4);
assert( abs(mean(electrons,'all')/3272.42266414141 - 1) < 1e-4);
assert(sensorGet(sensor,'nfilters') == 1);

%% END

end
