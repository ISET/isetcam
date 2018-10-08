function fig = CalibratePlotGamma(cal,fig)
% fig = CalibratePlotGamma(cal,[fig])
%
% Make a diagnostic plot of the gamma data and fits in the
% calibration structure.
%
% Can pass figure handle. Returns figure handle.
%
% See also CalibratePlotSpectra, CalibratePlotAmbient.
%
% 6/5/10  dhb  Wrote it.

% Optional figure open
if (nargin < 2 || isempty(fig))
    fig = figure;
end

clf;
if (size(cal.rawdata.rawGammaTable,2) > 3)
    subplot(1,2,1);
end
hold on
if (size(cal.rawdata.rawGammaInput,2) == 1)
    plot(cal.rawdata.rawGammaInput,cal.rawdata.rawGammaTable(:,1),'r+');
    plot(cal.rawdata.rawGammaInput,cal.rawdata.rawGammaTable(:,2),'g+');
    plot(cal.rawdata.rawGammaInput,cal.rawdata.rawGammaTable(:,3),'b+');
else
    plot(cal.rawdata.rawGammaInput(:,1),cal.rawdata.rawGammaTable(:,1),'r+');
    plot(cal.rawdata.rawGammaInput(:,2),cal.rawdata.rawGammaTable(:,2),'g+');
    plot(cal.rawdata.rawGammaInput(:,3),cal.rawdata.rawGammaTable(:,3),'b+');
end
xlabel('Input value', 'Fontweight', 'bold');
ylabel('Normalized output', 'Fontweight', 'bold');
title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
plot(cal.gammaInput,cal.gammaTable(:,1),'r');
plot(cal.gammaInput,cal.gammaTable(:,2),'g');
plot(cal.gammaInput,cal.gammaTable(:,3),'b');
axis([0 1 0 1.2]);
if (size(cal.rawdata.rawGammaTable,2) > 3)
    subplot(1,2,2); hold on
    if (size(cal.rawdata.rawGammaInput,2) == 1)
        plot(cal.rawdata.rawGammaInput,cal.rawdata.rawGammaTable(:,4),'r+');
        plot(cal.rawdata.rawGammaInput,cal.rawdata.rawGammaTable(:,5),'g+');
        plot(cal.rawdata.rawGammaInput,cal.rawdata.rawGammaTable(:,6),'b+');
    else
        plot(cal.rawdata.rawGammaInput(:,1),cal.rawdata.rawGammaTable(:,4),'r+');
        plot(cal.rawdata.rawGammaInput(:,2),cal.rawdata.rawGammaTable(:,5),'g+');
        plot(cal.rawdata.rawGammaInput(:,3),cal.rawdata.rawGammaTable(:,6),'b+');
    end
    xlabel('Input value', 'Fontweight', 'bold');
    ylabel('Normalized output', 'Fontweight', 'bold');
    title('Gamma correction', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    hold on
    plot(cal.gammaInput,cal.gammaTable(:,4),'r');
    plot(cal.gammaInput,cal.gammaTable(:,5),'g');
    plot(cal.gammaInput,cal.gammaTable(:,6),'b');
    axis([0 1 -1.2 1.2]);
end
drawnow;

