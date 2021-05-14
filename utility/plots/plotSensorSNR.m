function [uData,figHdl] = plotSensorSNR(sensor)
%Graph sensor SNR as a function of voltage level
%
%    [uData, figHdl] = plotSensorSNR([sensor])
%
% The SNR is computed in the routine sensorSNR.  See the comments there for
% the method.
%
% The computed values are attached to the figure in 'userdata', and they
% can be retrieved by get(gcf,'userdata').
%
% The black line in the graph shows the overall sensor SNR.  The colored
% lines show the SNR limit imposed by different factors (e.g., read noise
% shot noise, prnu, dsnu).
%
% See also: sensorSNR, pixelSNR
%
% Example:
%   sensor = sensorCreate;
%   plotSensorSNR(sensor)
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end

[snr,volts,snrShot,snrRead,snrDSNU,snrPRNU] = sensorSNR(sensor);
uData.volts = volts;
uData.snr = snr;

figHdl = vcNewGraphWin;

% Plot total with a thick line
p = semilogx(volts,snr,'k-'); set(p,'linewidth',2); hold on;

% There is always some shot noise
semilogx(volts,snrShot,'r-'); hold on;

% There may be 0 noise for these others.  It is depressing that don't have
% a separate line for reset noise.  It is just bundled in with read noise
% I guess.  Maybe I should change this and separate them out some day.
if ~isinf(snrRead), semilogx(volts,snrRead,'g-'); hold on; end
if ~isinf(snrDSNU), semilogx(volts,snrDSNU,'b-'); hold on; end
if ~isinf(snrPRNU), semilogx(volts,snrPRNU,'m-'); hold on; end

lgnd = {'Total','Shot'};
if ~isinf(snrRead), lgnd{end+1} = 'Read'; end
if ~isinf(snrDSNU), lgnd{end+1} = 'DSNU'; end
if ~isinf(snrPRNU), lgnd{end+1} = 'PRNU'; end

hold off; grid on;
legend(lgnd);

xlabel('Signal (V)');
ylabel('SNR (db)')
title('Sensor SNR over response range');

% Attach data to the figure
set(figHdl,'Userdata',uData);

return;
