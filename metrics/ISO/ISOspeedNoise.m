% Script:
%
%  Graph sensor SNR (db) vs. input illuminance (lux-sec) or
%
% To run this script, you should first use the GUI to create a uniform
% scene and calculate the optical image. Make sure that the off-axis fall
% off is turned off or else this variance will be counted as part of the
% sensor variance.
%
% Then, set up your sensor parameters in the sensor window.
% Then, run this script.  The output figure shows the
% sensor SNR (db) as a function of lux-sec;
% It is also possible to show SNR vs. sensor voltage, though this figure is
% commented out in the script.

% We can read this lux value here as the mean illuminance of the scene.
[valOI, OI] = vcGetSelectedObject('OI');
[illuminance, lux] = oiCalculateIlluminance(OI);

% In the sensor window, set up the parameters and compute the sensor
% image.  We  read read the sensor image parameters here.  If you change
% them in the window, you must re-run this code.
[valISA, ISA] = vcGetSelectedObject('ISA');

% Find the maximum exposure time prior to saturation.
ISA.integrationTime = autoExposure(OI, ISA);

% Choose the exposure times for the experiment, spanning 4 log units.
expTime = logspace(log10(sensorGet(ISA, 'integrationtime'))-4, log10(sensorGet(ISA, 'integrationtime')), 10);

% I like flipping the times when debugging:
% expTime = fliplr(expTime);

luxsec = lux * expTime;
% Turn off auto-exposure
ISA.AE = 0;

% Perform the experiments
snr = [];
for ii = 1:length(expTime)
    ISA.integrationTime = expTime(ii);
    ISA = sensorCompute(ISA, OI);
    volts = sensorGet(ISA, 'volts');

    % If there are more than one sensor type, compute the
    % SNR separately for each of the sensor classes.
    nSensors = sensorGet(ISA, 'ncolors');
    if nSensors > 1
        volts = plane2rgb(volts, ISA);
        for jj = 1:nSensors
            tmp = volts(:, :, jj);
            l = isfinite(tmp);
            meanVolts(ii, jj) = mean(tmp(l));
            stdVolts(ii, jj) = std(tmp(l));
            snr(ii, jj) = 20 * log10(meanVolts(ii, jj)/stdVolts(ii, jj));
        end
    else
        l = isfinite(volts);
        meanVolts(ii) = mean(volts(l));
        stdVolts(ii) = std(volts(l));
        snr(ii) = 20 * log10(meanVolts(ii)/stdVolts(ii));
    end
end

% Make the lux-sec version of the plot
figNum = vcNewGraphWin;
filterType = sensorGet(ISA, 'filterType');
switch filterType
    case 'rgb'
        semilogx(luxsec, snr(:, 1), 'r', luxsec, snr(:, 2), 'g', luxsec, snr(:, 3), 'b');
    case 'cmy'
        semilogx(luxsec, snr(:, 1), 'c', luxsec, snr(:, 2), 'm', luxsec, snr(:, 3), 'y');
end
grid on
xlabel('lux-sec');
ylabel('SNR (db)');
title('Sensor SNR vs. Lux-sec');

% Uncomment this code to show the SNR vs. voltage form of the plot.
% This is really the same plot as can be obtained from the pull-down menu by
% a theoretical analysis of the SENSOR->SNR
% This graph is not really needed.
% figNum = vcNewGraphWin;
% switch filterType
%     case 'rgb'
%         semilogx(meanVolts(:,1),snr(:,1),'r',meanVolts(:,2),snr(:,2),'g',meanVolts(:,3),snr(:,3),'b');
%     case 'cmy'
%         semilogx(meanVolts(:,1),snr(:,1),'c',meanVolts(:,2),snr(:,2),'m',meanVolts(:,3),snr(:,3),'y');
% end
% grid
% hold off; grid on
% xlabel('Signal (volts)'); ylabel('SNR (db)'); title('Sensor SNR vs. Volts');
