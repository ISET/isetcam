% v_sensorPoisson
%
% Check the Poisson returns when noiseFlag = -2
%
%

%% Make a uniform scene, pretty big
scene = sceneCreate('uniform');  % Mean luminance is 100 cd/m2
scene = sceneSet(scene,'fov',10);

% Create the optical image
oi = oiCreate; oi = oiCompute(oi,scene);

%% For a monochrome sensor, look at the center of the uniform image
sensor = sensorCreate('monochrome');
sensor = sensorSetSizeToFOV(sensor,8);

% Set the noise flag to Poisson noise only
sensor = sensorSet(sensor,'noise flag',-2);

sensor = sensorSet(sensor,'exp time',0.025/3000);  % Very short exposure
sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor,'scale',true);

%% Plot histogram and the Poisson histogram together

e = sensorGet(sensor,'electrons');
lambda = mean(e(:));

%%
vcNewGraphWin;
nSamps = length(e(:));
hist(e(:),100);
val = iePoisson(lambda,nSamps);
X = [e(:), val(:)];
thisHist = histogram(X,'Normalization','probability');


%% Poisson formula for lambda
samples  = 0:round(5*lambda);
nSamples = length(samples);
p = zeros(nSamples,1);
for ii=0:(nSamples-1)
    p(ii+1) = exp(-lambda)*((lambda^ii)/factorial(ii));
end
hold on
plot(samples,p,'ro--');

%% END






