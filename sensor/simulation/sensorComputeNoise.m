function sensor = sensorComputeNoise(sensor, wBar)
% Add noise, adjust analog gain, clip and quantize sensor voltage data
%
%  sensor = sensorComputeNoise(sensor,[wBar = []])
%
% On entry, sensor should contain the mean voltage, say computed with the
% noise flag set to no noise, as in sensorSet(sensor,'noise flag',0);
%
% This routine also adjusts for analog gain, clips, and quantizes.  See
% sensorCompute() for more information.
%
% To suppress the display of waitbars, set wBar to [].
%
%  Example:
%     sensor = sensorComputeNoise(sensor);
%     sensor = sensorComputeNoise(sensor,[]);
%
% Copyright ImagEval Consultants, LLC, 2011.

%% Define parameters
if ~exist('sensor', 'var') || isempty(sensor), errordlg('Image sensor array required.'); end
if ~exist('wBar', 'var') || isempty(wBar), showWaitBar = 0;
else, showWaitBar = 1;
end

warning('sensorComputeNoise:NoiseIssues', 'Must be updated for new noise model');

    % Use the noiseFlag here for God's sake
    % There are different conditions that should be matched with what we do in
    % sensorCompute
    %

    %% Sensor electrical and photon noise
    % If the user doesn't want any noise, they should not be here at all.  That
    % condition should be tested in the sensorCompute, before we get here.  If
    % we get here, we definitely get photon (shot) noise.  But we might turn
    % off the electronic noise, which is specified in another flag.
    sensor = sensorAddNoise(sensor);

    %% Analog gain simulation
    % We check for an analog gain and offset.  For many years there was no
    % analog gain parameter.  This was added in January, 2008 when simulating
    % some real devices. The manufactureres  Were clamping at zero and using
    % the analog gain like wild men, rather than exposure duration. We set it
    % in script for now, and we will add the ability to set it in the GUI
    % before long.  If these parameters are not set, we assume they are
    % returned as 1 (gain) and 0 (offset).
    ag = sensorGet(sensor, 'analog gain');
    ao = sensorGet(sensor, 'analog offset');
    if ag ~= 1 || ao ~= 0
        volts = sensorGet(sensor, 'volts');
        volts = (volts + ao) / ag;
        sensor = sensorSet(sensor, 'volts', volts);
    end

    %% Clipping
    % We clip the voltage because we assume that everything must fall between 0
    % and voltage swing.
    pixel = sensorGet(sensor, 'pixel');
    vSwing = pixelGet(pixel, 'voltage swing');
    sensor = sensorSet(sensor, 'volts', ieClip(sensorGet(sensor, 'volts'), 0, vSwing));

    %% Quantization
    % Compute the digital values (DV).   The results are written into
    % sensor.data.dv.  If the quantization method is Analog, then the data.dv
    % field is cleared and the data are stored only in data.volts.

    if showWaitBar, waitbar(0.95, wBar, 'Sensor image: A/D'); end
    switch lower(sensorGet(sensor, 'quantization method'))
        case 'analog'
            % dv = [];
            sensor = sensorSet(sensor, 'volts', analog2digital(sensor, 'analog'));
        case 'linear'
            sensor = sensorSet(sensor, 'digital values', analog2digital(sensor, 'linear'));
        case 'sqrt'
            sensor = sensorSet(sensor, 'digital values', analog2digital(sensor, 'sqrt'));
        case 'lut'
            warning('sensorComputeNoise:LUT', 'LUT quantization not yet implemented.')
        case 'gamma'
            warning('sensorComputeNoise:Gamma', 'Gamma quantization not yet implemented.')
        otherwise
            sensor = sensorSet(sensor, 'digitalvalues', analog2digital(sensor, 'linear'));
    end

    return
