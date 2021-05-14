function sensor = sensorWBCompute(sensor,workDir,displayFlag)
% Compute sensor response one waveband at a time (to reduce memory usage)
%
%   sensor = sensorWBCompute(sensor,workDir,displayFlag)
%
% This routine loops through the oiXXX.mat files in the workDir directory
% to calculate the sensor responses. The calculation converts OI data to
% volts, one waveband at a time, and the voltages are added together.  The
% results are returned in sensor.
%
% The routine creates a version of sensor that is noise free and calculates
% the voltages for the first N-1 wavebands.  Then it calculates the last
% wavelength with the noise parameters of the original.  In this way, the
% routine only adds the sensor noise once.  The photon noise is added
% across the wavebands.
%
% The analog to digital conversion is performed at the last stage, after
% the (continuous) voltage level has been accumulated.
%
% See s_wavebandCompute for an example of how this routine is used.
%
% See also:  sceneWBCreate
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('sensor'), error('You must specify the sensor'); end
if ieNotDefined('workDir'), error('You must specify the directory with OI files.'); end
if ieNotDefined('displayFlag'), displayFlag = 0; end

% Figure for updating
displayFig = 99;

sensorL = sensorNoNoise(sensor);
t = dir([workDir,filesep,'oi*.mat']);
nWave = length(t);
chdir(workDir);
volts = zeros(sensorGet(sensor,'size'));
wBar = waitbar(0,'oi-sensor waveband compute');
for ii=1:(nWave-1)
    waitbar(ii/nWave,wBar);
    load(t(ii).name);
    
    % sensorCompute adjusts the spectral properties of the sensor to match
    % the optical image.  So, in this routine, we create a tmpSensor that
    % is discarded.
    tmpSensor = sensorCompute(sensorL,opticalimage,0);
    volts = volts + sensorGet(tmpSensor,'volts');
    if displayFlag,
        figure(displayFig);
        sensor = sensorSet(sensor,'volts',volts);
        sensorShowImage(sensor);
    end
end
close(wBar);

% Now compute one step with the noise, but not quantized
load(t(nWave).name);
sensor = sensorCompute(sensor,opticalimage,0);
volts = volts + sensorGet(sensor,'volts');

% Store volts, possibly quantizing.
sensor = sensorSet(sensor,'volts',volts);
qMethod = sensorGet(sensor,'quantizationmethod');
if ~strcmp(qMethod,'analog')
    sensor = sensorSet(sensor,'volts',analog2digital(sensor,qMethod));
end

sensorName = ['wb-',oiGet(opticalimage,'name')];
sensor = sensorSet(sensor,'name',sensorName);

return;