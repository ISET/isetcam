% SENSOR
%
% Files
%   s_sensorAnalyzeDarkVoltage - Simulating the measurement of sensor dark voltage
%   s_sensorCountingPhotons    - Calculate the number of photons at a pixel
%   s_sensorExposureBracket    - Simulate exposure bracketing with sensorCompute
%   s_sensorExposureCFA        - Experiments setting exposure separately for each color channel
%   s_sensorExternalAnalysis   - Create a sensor with properties of your device
%   s_sensorHDR_PixelSize      - Simulate a sensor that combines data from multiple pixel sizes.
%   s_sensorMCC                - Converts the a tiff file into ISET sensor format.
%   s_sensorMicrolens          - Calculations for a microlens array on the sensor
%   s_sensorNoise              - Measure different sensor noise
%   s_sensorPlotColorFilters   - Plots the transmissivities of color filters
%   s_sensorRollingShutter     - Simulate rolling shutter effects
%   s_sensorSizeResolution     - Count pixels for a particular sensor (quarterinch, halfinch)
%   s_sensorSNR                - How pixel and sensor parameters influence sensor SNR.
%   s_sensorSpatialNoiseDSNU   - An experimental approach to measuring DSNU .
%   s_sensorSpatialNoisePRNU   - Problems with the experimental approach of measuring PRNU
%   s_sensorSpectralEstimation - Estimate color filter responsivities
%   s_sensorStackedPixels      - Simulate a sensor with stacked pixels, as in the Foveon sensor
%   t_sensorEstimation         - Review of sensor estimation for spectral QE (Psych 221)
%   t_sensorExposureColor      - Over-exposure causes color errors
%   t_sensorInputRefer         - Calculate the mean absorption rate at a detector
%   t_sensorSpatialResolution  - Illustration of pixel size (sensor spatial resolution) and aliasing
