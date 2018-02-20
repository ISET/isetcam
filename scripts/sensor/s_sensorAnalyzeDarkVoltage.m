%% Simulating the measurement of sensor dark voltage
%
% To measure *sensor dark voltage* take a picture of a zero
% intensity scene (lens cap on) at different exposure durations.
% The average dark voltage (mv/sec) is measured from the slope
% (pooling all the pixels) of the (voltage vs. time) curve.
%
% In addition to the dark voltage estimate (V/s), we calculate
% the mean voltage at each exposure duration.
%
% The curve plot(expTimes,meanVolts) shows the measured data. 
%
% See also:  sceneCreate, sceneAdjustLuminance, oiCreate,
% sensorCompute, ieSessionGet, ieFitLine
%   
% Copyright ImagEval Consultants, LLC, 2005.

%%
ieInit

%% Make a black (very dark) scene 
scene     = sceneCreate('uniform ee');
scene     = sceneSet(scene,'fov',5);  % Five degrees
darkScene = sceneAdjustLuminance(scene,1e-8);

%% Compute the optical image
oi = vcGetObject('opticalimage');
if isempty(oi), oi = oiCreate('default',[],[],0); end
darkOI = oiCompute(darkScene,oi);


%% Create a sensor 
sensor = sensorCreate;

% Set a range of exposure times
expTimes = logspace(0,1.5,10); 

% For the default camera, at the shortest exposure (1 sec), we will see a
% significant component of noise from other sources.  The other terms,
% however, are dominated by the dark voltage.

% How many color filters?
nFilters = sensorGet(sensor,'nfilters');


%% Compute the responses at different exposure times

clear volts
nRepeats = length(expTimes);
showBar = ieSessionGet('waitbar');
if showBar, wBar = waitbar(0,'Acquiring images'); end

% Compute the sensor responses 
nSamp = prod(sensorGet(sensor,'size'))/2;
volts = zeros(nSamp,nRepeats);
for ii=1:nRepeats
    if showBar, waitbar(ii/nRepeats,wBar); end
    sensor = sensorSet(sensor,'exposureTime',expTimes(ii));
    sensor = sensorCompute(sensor,darkOI,0);
    if nFilters == 3
        volts(:,ii) = sensorGet(sensor,'volts',2);
    elseif nFilters == 1
        tmp = sensorGet(sensor,'volts');
        volts(:,ii) = tmp(:);
    end
end
if showBar, close(wBar); end

%% Compute the mean voltage across all the pixels at each exposure duration.

% You can select the shortest exposure duration used in the fitting by
% adjusting the parameter shortestTime. Hint: Try using 4.
shortestTime = 1; list = shortestTime:length(expTimes);
meanVolts = mean(volts,1);
[darkVoltageEstimate,o] = ieFitLine(expTimes(list),meanVolts(list));

%% Plot the data and analyze the values.

% For dark voltage, we use long exposure times.  This gives the voltage
% time  to  become significantly larger than the other types of noise. In
% this simulation case, we read the voltages at the sensor.  In many
% practical cases, however, you do not have access to the raw camera
% voltages.  Typically, you might have access only to the digital values.
% If that is all you have, it will be necessary to find ways to estimate
% the volts from the digital values.

vcNewGraphWin;
title('Measured voltages')
plot(expTimes(list),meanVolts(list),'-o');
xlabel('Exposure time (s)'); ylabel('Voltage (v)'); 
grid on

pixel = sensorGet(sensor,'pixel');
trueDV = pixelGet(pixel,'darkvoltage');
fprintf('---------------------------\n')
fprintf('True dark voltage: %.5f\n',trueDV);
fprintf('Estimated:  %.5f\n',darkVoltageEstimate);
fprintf('Percent error: %.2f\n', 100*(trueDV- darkVoltageEstimate )/trueDV )
fprintf('---------------------------\n')

%
assert(abs(darkVoltageEstimate - trueDV) < trueDV*1e-2,'Bad dark voltage estimate');
%% 
