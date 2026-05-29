function tests = test_ipTransforms()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% Calculate the ip color transforms in different ways
%
% We want to be able to calculate these without calling the full
% ipCompute() method. This validation illustrates the three methods
% and validates that these three approaches all return the same full
% transforms.
%

%% We need a small scene and oi

scene = sceneCreate('macbeth d65',32);
scene = sceneSet(scene,'fov',20);
oi = oiCreate('wvf');
oi = oiCompute(oi,scene);


sensorRGB = sensorCreate('ar0132at',[],'rgb');
sensorRGB = sensorSet(sensorRGB,'noise flag',0);
sensorRGB = sensorCompute(sensorRGB,oi);

%% This is how it is computed within ipCompute 

ip = ipCreate;
ip = ipCompute(ip,sensorRGB);  % Computes the Transforms
T1 = ipGet(ip,'prodT');

%% Avoids ipCompute. But uses the whole sensor

sensorRGB = sensorCreate('ar0132at',[],'rgb');
T{1} = ieColorTransform(sensorRGB,'XYZ','D65','mcc');
T{2} = eye(3,3);
T{3} = ieInternal2Display(ip);
ip = ipSet(ip,'transforms',T);
T2 = ipGet(ip,'prodT');

% Validation 1
assert( max(abs((T1(:) - T2(:)))) < 1e-6)

%% Uses only the three color filters from a sensor

% These match!  So write a routine to get the transforms based on the
% RGB of the RGBW sensor.  No need to create the RGB and run an
% ipCompute to calculate the transforms.
sensorRGBW = sensorCreate('ar0132at',[],'rgbw');
wave     = sensorGet(sensorRGBW,'wave');
sensorQE = sensorGet(sensorRGBW,'spectral qe');
targetQE = ieReadSpectra('xyzQuanta',wave);
T{1} = imageSensorTransform(sensorQE(:,1:3),targetQE,'D65',wave,'mcc');
T{2} = eye(3,3);
T{3} = ieInternal2Display(ip);
ip = ipSet(ip,'transforms',T);
T3 = ipGet(ip,'prodT');

% Validation 2
assert( max(abs((T1(:) - T3(:)))) < 1e-6)

%% End
end
