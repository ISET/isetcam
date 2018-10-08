function fig = CalibratePlotSpectra(cal,fig)
% fig = CalibratePlotSpectra(cal,[fig])
%
% Make a diagnostic plot of the device spectral data and fits in the
% calibration structure.
%
% Can pass figure handle. Returns figure handle.
%
% See also CalibratePlotGamma, CalibratePlotAmbient.
%
% 6/5/10  dhb  Wrote it.

% Optional figure open
if (nargin < 2 || isempty(fig))
    fig = figure;
end

clf; hold on
if (size(cal.rawdata.rawGammaTable,2) > 3)
    subplot(1,2,1);
end
hold on
plot(SToWls(cal.S_device),cal.P_device(:,1),'r');
plot(SToWls(cal.S_device),cal.P_device(:,2),'g');
plot(SToWls(cal.S_device),cal.P_device(:,3),'b');
xlabel('Wavelength (nm)', 'Fontweight', 'bold');
ylabel('Power', 'Fontweight', 'bold');
title('Phosphor spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
axis([380,780,-Inf,Inf]);
if (size(cal.rawdata.rawGammaTable,2) > 3)
    subplot(1,2,2); hold on
    plot(SToWls(cal.S_device),cal.P_device(:,4),'r');
    plot(SToWls(cal.S_device),cal.P_device(:,5),'g');
    plot(SToWls(cal.S_device),cal.P_device(:,6),'b');
    xlabel('Wavelength (nm)', 'Fontweight', 'bold');
    ylabel('Power', 'Fontweight', 'bold');
    title('Phosphor correction', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([380,780,-Inf,Inf]);
end
drawnow;
