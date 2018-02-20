function opticsPlotTransmittance(oi);
%Plot spectral transmittance of the optics
%
%   opticsPlotTransmittance(oi)
%
% Author: ImagEval
% Purpose:
%    Plot the transmittance of the lens and other intervening media. 
%
%    This slot is used to store the human macular pigment density.  It can
%    also be used to store the lens transmittance or the combination of the
%    two.
%
% Copyright ImagEval Consultants, LLC, 2003.

figNum =  vcSelectFigure('GRAPHWIN');
figNum =  plotSetUpWindow(figNum);

wave = oiGet(oi,'wave');
optics = oiGet(oi,'optics');
transmittance = opticsGet(optics,'transmittance');
if isempty(transmittance), transmittance = ones(size(wave)); end

plot(wave,transmittance,'-o')

udata.wave = wave; udata.transmittance = transmittance;
set(gca,'userdata',udata);
xlabel('Wavelength (nm)'); ylabel('Transmittance');
title('Optical transmittance');
grid on

return;