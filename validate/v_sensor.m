%% v_sensor
%
%  Scripts to run sensor and pixel functions
%
% Copyright ImagEval Consultants, LLC, 2011.

ieInit;

%% Basic sensor scripts

s_sensorCountingPhotons
s_sensorSNR
s_sensorAnalyzeDarkVoltage
s_sensorSpectralEstimation

if exist('s_sensorExposureCFA','file')
    s_sensorExposureCFA
end

if exist('s_sensorExposureBracket','file')
    s_sensorExposureBracket
end

%% Test chromaticity plot for sensor

scene = sceneCreate; camera=cameraCreate;
camera = cameraCompute(camera,scene);
sensor = cameraGet(camera,'sensor');
sensorWindow(sensor);

% sensorPlot(sensor,'chromaticity',[20 20 40 40]);

%% End