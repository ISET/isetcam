%% v_sensor
%
%  Scripts to run sensor and pixel functions
%
% Copyright ImagEval Consultants, LLC, 2011.

ieInit;

%%
% s_sensorPhotonsPerPixel - depreciated
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

%% End