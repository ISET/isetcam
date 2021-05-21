function [uData, figHdl] = plotPixelSNR(sensor)
%Graph the pixel SNR over the pixel response range
%
%    [uData, figHdl] = plotPixelSNR(sensor)
%
%  Three curves are generated.  One shows the total pixel SNR.  The other
%  two show the SNR limits from Shot Noise and from Read Noise,
%  respectively.
%
%  This routine usese the currently selected ISA structure to retrieve all
%  of the data and properties used for plotting.   Perhaps it should take
%  an ISA argument.
%
% Example:
%    plotPixelSNR;
%    [uData, g] = plotPixelSNR(vcGetObject('sensor'));
%
% (c) Imageval Consulting, LLC, 2012

if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
% SNRread can come back as Inf if there is no read noise.
[SNR, volts, SNRshot, SNRread] = pixelSNR(sensor);

uData.volts = volts;
uData.snr = SNR;
uData.snrShot = SNRshot;
uData.snrRead = SNRread;

figHdl = vcNewGraphWin;

p = semilogx(volts,SNR,'k-'); hold on; set(p,'linewidth',2);
p = semilogx(volts,SNRshot,'r-',volts,SNRread,'g-'); set(p,'linewidth',1);
hold off
grid on;
xlabel('Signal (V)');
ylabel('SNR (db)')
title('Pixel SNR over response range');
legend({'Total pixel SNR','Shot noise SNR','Read noise SNR'});

% Attach data to the figure
set(figHdl,'Userdata',uData);
return;
