function thirtyDBLevel = sensorMPE30(sensor)
% Compute a sensor's minimum photometric exposure (lux-sec) to obtain a 30dB SNR
%
%   thirtyDBLevel = sensorMPE30(sensor)
%
% If sensor is not defined, the current sensor settings are used.  This
% level is of interest because observers can just barely detect 3 percent
% (30dB) noise in a uniform image.  Hence, we use this lux-sec level to
% determine the noise threshold.
%
% If no output argument is requested, a graph is produced of snr vs.
% lux-sec and the MPE30 is in the title.
% Otherwise, the thirtyDBLevel is returned and no plot is generated.
%
% See also: sensorSNRluxsec
%
% Example:
%  sensorMPE30
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end

[snr, luxsec] = sensorSNRluxsec(sensor);
thirtyDBLevel = interp1(snr, luxsec, 30);

if nargout == 0
    % Plot the data.  Could add data to the userdata of the graph.
    semilogx(luxsec, snr);
    xlabel('Photometric Exposure (lux-sec)');
    ylabel('SNR (db)');
    grid on
    str = sprintf('MPE30 = %.3f', thirtyDBLevel);
    title(str)
end

return;
