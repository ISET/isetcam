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

%% This is a color sensor
sensor = sensorCreate;
sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor);

ip = ipCreate;
ip = ipCompute(ip,sensor); 
ipWindow(ip);

%% Now the monochrome sensor
sensor = sensorCreate('monochrome');
sensor = sensorSet(sensor,'noise flag',0);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

%% Show in the IP window
ip = ipCompute(ip,sensor); 
ipWindow(ip);

assert( abs (mean(ipGet(ip,'result'),'all')/0.327242224265567 - 1) < 1e-4)

%%
drawnow;

%% END

end
