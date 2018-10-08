function fig = CalibratePlotAmbient(cal,fig)
% fig = CalibratePlotAmbient(cal,[fig])
%
% Make a diagnostic plot of the ambient spectral data
%
% Can pass figure handle. Returns figure handle.
%
% See also CalibratePlotGamma, CalibratePlotSpectra.
%
% 6/5/10  dhb  Wrote it.

% Optional figure open
if (nargin < 2 || isempty(fig))
    fig = figure;
end

clf; hold on
plot(SToWls(cal.S_device),cal.P_ambient(:,1),'k');
xlabel('Wavelength (nm)', 'Fontweight', 'bold');
ylabel('Power', 'Fontweight', 'bold');
title('Ambient spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
axis([380,780,-Inf,Inf]);
drawnow;
