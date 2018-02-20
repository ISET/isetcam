%% Problems with the experimental approach of measuring PRNU 
%
% Photoreceptor response nonuniformity (PRNU) and dark-signal nonuniformity
% (DSNU) can be estimated by measuring a uniform scene at several exposure
% levels, taking care to avoid saturatation or values near zero. Then, one
% can find the slopes of the pixel responses, normalize them, and estimate
% the PRNU from the standard deviation of these slopes.
% 
% This script simulates that approach.  It shows that the photon noise
% *corrupts* the estimate.  Even when there is 0 PRNU, the PRNU appears to
% be on the order of 2 percent in the presence of photon noise.
%
% *Further observations*
%
% Notice that the slope of the pixel response depends on the level of the
% uniform field (it will be higher on a bright field).  To normalize for
% the level of the field, specify the standard deviation of the slope as a
% percentage of the mean slope.  You can do this by dividing all the slopes
% by the mean slope before calculating the standard deviation.  The mean
% slope is always 1 volt/sec.
%
% Copyright ImagEval Consultants, LLC, 2010.

%%
ieInit

%% Parameters

% scene parameters
meanL = 100; % Mean luminance
fov   = 2;   % Field of view

% Set to 0 implicitly when simulateNoise = 0
prnuLevel =  1;     % Std. dev of gain, around 1, as a percentage

% Other sensor noises
dsnuLevel = 0.00;   % Std. dev. of offset in volts
readNoise = 0.00;   % Read noise in volts
darkNoise = 0.00;   % Dark voltage in v/s

% Set a range of experimental exposure times (in secs)
expTime = (40:2:60)/1000;      % Times in sec
nRepeats = 3;                  % We can repeat the experiment a few times

%% Make a uniform scene, oi, and sensor
scene = sceneCreate('uniform ee');
scene = sceneAdjustLuminance(scene,meanL);
scene = sceneSet(scene,'fov',fov);

oi = oiCreate('default',[],[],0);
optics = oiSet(oi,'optics offaxis method','skip');  % No relative illumination

sensor = sensorCreate; 
sensor = sensorSet(sensor,'size',[196 196]);
sensor = sensorSet(sensor,'noise flag',2);

% Make the uniform scene larger than the sensor field of view.
scene = sceneSet(scene,'fov',sensorGet(sensor,'fov')*1.5);

% Compute the optical image
oi = oiCompute(scene,oi);
ieAddObject(oi);
oiWindow;

%% Set the sensor parameters

expTime = repmat(expTime,1,nRepeats);

sensor = sensorClearData(sensor);
sensor = sensorSet(sensor,'DSNU level',dsnuLevel);
sensor = sensorSet(sensor,'PRNU level',prnuLevel);
sensor = sensorSet(sensor,'pixel Read noise volts',readNoise);
sensor = sensorSet(sensor,'pixel Dark voltage',darkNoise);

% How many color filters?  Normally 3 and we use the 2nd one in a Bayer.
% But sometimes we might run this script with a monochrome.
nFilters = sensorGet(sensor,'nfilters');

%%  Acquire multiple short exposures of the dark image

% We take the image multiple times so we can average out the read noise
nTimes = length(expTime);

% Zero out the voltages
nSamp = prod(sensorGet(sensor,'size'))/2;
volts = zeros(nSamp,nTimes);

wBar = waitbar(0,'Acquiring images');
for ii=1:nTimes
    waitbar(ii/nTimes,wBar);
    sensor = sensorSet(sensor,'Exposure Time',expTime(ii));
    sensor = sensorCompute(sensor,oi,0);
    volts(:,ii) = sensorGet(sensor,'volts',2);
end
close(wBar);

%% Make sure the sensor was fully illuminated

% Should be uniform and filled up!
ieAddObject(sensor); sensorWindow('scale',true);

%% Compute the best-fitting line for expTime vs. voltage for each pixel

% volts' = expTime * x
% x = inv(A)*volts'
A = [expTime(:), ones(nTimes,1)];
x = A\volts';

slopes  = x(1,:);
slopes = slopes/mean(slopes(:));

% This is another way to estimate DSNU.
offsets = x(2,:);

%% Plot the data and analyze the values.

vcNewGraphWin; 
t = sprintf('Normalized slopes (photon noise)');

hist(slopes,50); title(t)
set(gca,'xlim',[0.9 1.1]);

PRNU = 100*std(slopes); % Std. of slope as a percentage (not fraction)

fprintf('---------------------------\n')
fprintf('PRNU percentage estimated is too high! %.1f\n',PRNU);
fprintf('---------------------------\n')


%%
