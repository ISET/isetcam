function udata = opticsPlotTransmittance(oi, thisW)
%Plot spectral transmittance of the optics
%
% Synopsis
%   udata = opticsPlotTransmittance(oi,thisW)
%
% Inputs
%       oi:
%    thisW:
%
%
% Description
%    Plot the transmittance of the lens and other intervening media.
%
%    This slot is used to store the human macular pigment density.  It can
%    also be used to store the lens transmittance or the combination of the
%    two.
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also
%    oiPlot

%{
oi = oiCreate;
opticsPlotTransmittance(oi);
%}
%{
oi = ieGetObject('oi');
opticsPlotTransmittance(oi);

%}

%% Set up the parameters

if ieNotDefined('oi'), error('oi required.'); end
if ieNotDefined('thisW'), thisW = ieNewGraphWin; end

wave = oiGet(oi, 'wave');
if isempty(wave), warning('oi not fully specified yet.');
    return;
end

optics = oiGet(oi, 'optics');
transmittance = opticsGet(optics, 'transmittance', wave);

if isempty(transmittance), transmittance = ones(numel(wave), 1); end

%% Plot it
figure(thisW);
plot(wave, transmittance, '-o')

%% Store the data

udata.wave = wave;
udata.transmittance = transmittance;
set(gca, 'userdata', udata);
xlabel('Wavelength (nm)');
ylabel('Transmittance');
title('Optical transmittance');
grid on

end