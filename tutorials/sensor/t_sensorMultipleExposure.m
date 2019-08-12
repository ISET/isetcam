%% Multiple exposures
%
% Multiple capture (e.g., bracketing) and burst photography modes are
% common.  Here are some examples of running these simulations in ISETCam.
%
%
% Wandell, 2019
%
% See also
%

%%
ieInit

%% Set up the default scene and the oi

% We will use an HDR scene before long, rather than this default.
scene = sceneCreate;
oi = oiCreate; oi = oiCompute(oi,scene);

%% Run the sensor simulation

sensor = sensorCreate; 
sensor = sensorSet(sensor,'fov',sceneGet(scene,'fov'));

% expTime   = autoExposure(oi,sensor);
expTime = 0.3;   % 300 ms
sensor = sensorSet(sensor,'exp time',expTime);  % 100 ms
sensor = sensorCompute(sensor,oi); 
sensorWindow(sensor);

%% Multiple exposure values

% Simple bracketing case.  Increasing order of equally scaled exposure
% times.
sFactor   = 4;
burstTiming  = [expTime/(sFactor*sFactor), expTime/sFactor, expTime];
sensorMEV = sensorSet(sensor,'exp time',burstTiming);

% Get the multiple exposures.  This will display in bracketing mode
sensorMEV = sensorCompute(sensorMEV,oi);
sensorWindow(sensorMEV);

%% One of many combination methods

% Get the voltages from the multiple exposures
volts      = sensorGet(sensorMEV,'volts');
vSwing     = sensorGet(sensorMEV,'pixel voltage swing');
nExposures = sensorGet(sensorMEV,'n exposures');

% Start out with the volts from the longest exposure time
combinedV = volts(:,:,end);

% Find the saturated pixels and replace them with estimates from
% shorter durations.  These may be saturated, too.  So, we loop down until
% there are no saturated pixels
thisExp = 1;
maxV = vSwing*0.95;
for thisExposure = (nExposures - 1):-1:1
    % Find the saturated pixels for this level
    lst = (combinedV > maxV);
    fprintf('Exposure %d.  Replacing %d pixels\n',thisExposure,sum(lst(:)));
    if sum(lst(:)) == 0, break
    else
        % Scaled volts from the shorter duration.
        theseV = volts(:,:,thisExposure)*(sFactor^thisExp);
        combinedV(lst) = theseV(lst);
        maxV = maxV*sFactor;
        thisExp = thisExp + 1;
    end
end

sensor = sensorSet(sensor,'pixel voltage swing',max(combinedV(:))/0.95);
sensor = sensorSet(sensor,'volts',combinedV);
sensor = sensorSet(sensor,'name','combined MEV');
sensorWindow(sensor);

%% Burst photography example

burstTiming = repmat(expTime/5,1,5);
sensor      = sensorSet(sensor,'exp time',burstTiming);
sensorBurst = sensorCompute(sensor,oi);
sensorBurst = sensorSet(sensorBurst,'name',sprintf('burst-%d',numel(burstTiming)));
sensorBurst = sensorSet(sensorBurst,'exp time',burstTiming(1));
volts = sensorGet(sensorBurst,'volts');
volts = sum(volts,3);
sensorBurst = sensorSet(sensorBurst,'volts',volts);
sensorWindow(sensorBurst);

% Line is (x,y), not row,col.  (1,1) is upper left corner.
sensorPlot(sensorBurst,'volts hline',[1,163]);


%% 




