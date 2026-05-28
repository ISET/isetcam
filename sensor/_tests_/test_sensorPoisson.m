function tests = test_sensorPoisson()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
% v_sensorPoisson
%
% Check the Poisson returns when noiseFlag = -2
%
%

%%
ieInit;

%% Compare the timing on a large poissrnd call and a randn call
e = randn([1024 1024]);
tic
randn(size(e)) .* sqrt(e); %#ok<VUNUS> 
g = toc;
tic
poissrnd(e);
p = toc;
fprintf('Poisson to Gauss timing ratio for 1M samples:  %f\n',p/g)

%% Make a uniform scene, pretty big
scene = sceneCreate('uniform');  % Mean luminance is 100 cd/m2
scene = sceneSet(scene,'fov',10);

% Create the optical image
oi = oiCreate; oi = oiCompute(oi,scene);

%% For a monochrome sensor, look at the center of the uniform image
sensor = sensorCreate('monochrome');
fov = 8;
sensor = sensorSetSizeToFOV(sensor,fov,oi);

% Set the noise flag to Poisson noise only
sensor = sensorSet(sensor,'noise flag',-2);

sensor = sensorSet(sensor,'exp time',0.025*(3*1e-4));  % Very short exposure
sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor,'scale',true);

e = sensorGet(sensor,'electrons');
lambda = mean(e(:));
assert(lambda > 0);

%% Now for a longer exposure
sensor = sensorSet(sensor,'exp time',0.025*(3*1e-4)*100);  % Long exposure
sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor,'scale',true);

e = sensorGet(sensor,'electrons');
lambda = mean(e(:));

%% Poisson formula means it should be fit by a Gaussian and
% the std dev should be sqrt(mean)
%
sd = sqrt(lambda);
[mn,sigma] = normfit(e(:));
fprintf('\n-----\n');
fprintf('Nominal: std dev %.2f\n',sd);
fprintf('Data:    std dev %.2f\n',sigma);
fprintf('-----\n');
assert(abs(sigma/sd - 1) < 0.1,'Poisson electron standard deviation is unexpected');

%% END







end
