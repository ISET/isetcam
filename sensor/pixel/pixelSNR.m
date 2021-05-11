function [SNR, volts, SNRshot, SNRread] = pixelSNR(sensor, volts)
%Compute pixel SNR as a function of pixel voltage
%
%   [SNR, volts, SNRshot, SNRread] = pixelSNR(sensor,volts)
%
% The pixel SNR depends on the signal level (in volts) or these can be
% stimulus referred to lux-sec (see pixelSNRluxsec). The SNR is returned in
% decibels (dB).
%
% The formula for pixel signal-to-noise ratio is
%
%    SNR = 10 * log10(signalPower./noisePower);
%
% where
%
%  signalPower:   the square of the number of electrons (volts/convGain).^2;
%
%  noisePower:    the sum of the read noise variance and shot noise
%  variance (readSD.^2 + shotSD.^2), both in electrons.
%
% If no voltage levels are passed in, we choose volts to be logarithmically
% spaced across the pixel voltage range.
%
% The limitations imposed by the different noise types (shot noise and read
% noise) can be returned, as well.
%
% See also:  pixelSNRluxsec, sensorSNR (and the comments there)
%
% Examples:
%   sensor = sensorCreate;
%   [SNR, volts] = pixelSNR(sensor); semilogx(volts,SNR);
%   [SNR, volts, SNRshot, SNRread] = pixelSNR(sensor);
%
%   vcNewGraphWin;
%   semilogx(volts,SNRshot,'g--',volts,SNRread,'r-',volts,SNR,'k-');
%   legend('Shot noise SNR','Read noise SNR','Total SNR');
%   grid on
%
% Note:  (1) The argument to this routine is a sensor array with an attached pixel.
% Note:  (2) If the read SD is 0, we treat the readSNR as infinite.
%
% Copyright ImagEval Consultants, LLC, 2005

if ieNotDefined('sensor'), [val, sensor] = vcGetSelectedObject('ISA'); end

pixel = sensorGet(sensor, 'pixel');
if ieNotDefined('volts'),
    voltageSwing = pixelGet(pixel, 'voltageswing');
    volts = logspace(-4, 0) * voltageSwing;
end

convGain = pixelGet(pixel, 'conversionGain'); % V/e-
readSD = pixelGet(pixel, 'readNoiseElectrons'); % e-

% Shot noise is Poisson when measured in units of electrons. Conversion
% gain has units of v/e-.  So volts/convGain is the mean number of
% electrons.  This number is also the Poisson variance. The variance has
% units of electrons squared. The standard deviation is the square root of
% the mean and it has units of electrons.
shotSD = sqrt(volts/convGain); % signal SD e-

% The power has units of electrons squared
signalPower = (volts / convGain).^2; % e-^2
noisePower = readSD.^2 + shotSD.^2; % e-^2

% 10 instead of 20 because we have squared the signal above and are using
% signal Power.
SNR = 10 * log10(signalPower./noisePower);

if nargout > 2
    % User asked for shot noise contribution alone
    noisePower = shotSD.^2; % e-
    SNRshot = 10 * log10(signalPower./noisePower);
end

if nargout > 3
    % User asked for read noise contribution alone
    if readSD == 0
        SNRread = Inf;
    else
        noisePower = readSD.^2; % e-
        SNRread = 10 * log10(signalPower./noisePower);
    end
end

return
