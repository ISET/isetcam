function [SNR, volts, SNRshot, SNRread, SNRdsnu, SNRprnu] = sensorSNR(ISA,volts)
%Calculate sensor SNR over a range of voltage levels
%
%   [SNR, volts, SNRshot, SNRread, SNRdsnu, SNRprnu] = sensorSNR(ISA,volts)
%
% The formula for sensor SNR is
%
%      SNR = 10*log10(signalPower/noisePower)
%
% We compute this in units of electrons.  The definitions of signalPower
% and noisePower are:
%
%  signalPower:  the number of signal electrons squared. 
%    signalPower = (volts/convGain).^2;
%
%  noisePower:   the sum of the variance of the shot noise, read noise,
%    and prnu noise.
%    noisePower = shotSD.^2 + readSD.^2 + dsnuSD.^2 + prnuSD.^2;
%
% The values are all calculated in electrons, not volts.  This is because
% the shot noise is Poisson in electrons, not volts.
%
% Various noise quantities are signal-dependent, such as the Poisson
% variability in the number of electrons (shot noise) and the
% photo-response nonuniformity (prnu).  Other noise factors are signal
% indpendent (readSD, dsnuSD). 
%
% See comments in the code for more information about the calculation.
%
% If no voltage levels are sent in we calculate as a function across the
% voltage swing. This function is similar to pixelSNR, but also includes
% DSNU and PRNU. 
%
% This routine can also return the SNR limits imposed by the individual
% noise sources. If the modeling sets  readSD, dsnuSD, prnuSD to  we
% return an infinite SNR.
%
% See also:  s_sensorSNR, pixelSNR
%
% Examples:
%   sensor = vcGetObject('sensor');
%   [SNR, volts] = sensorSNR(sensor); 
%   vcNewGraphWin; semilogx(volts,SNR);
%   peakSNR = sensorSNR(sensor,saturationVoltage);
%
% Copyright ImagEval Consultants, LLC, 2005

if ieNotDefined('ISA'), [val,ISA] = vcGetSelectedObject('ISA'); end
pixel = sensorGet(ISA,'pixel');

if ~exist('volts','var'), volts = logspace(-4,0)*pixelGet(pixel,'voltageswing'); end % Volts

convGain = pixelGet(pixel,'conversionGain');        % V/e-
readSD = pixelGet(pixel,'readnoiseElectrons');      % e-

% Gain std as a percentage change in the voltage slope. 
% gainImage = 1 + randn()*(sigmaGainFPN/100)
gainSD = sensorGet(ISA,'gainSD');
gainSD = gainSD/100;

offsetSD = sensorGet(ISA,'offsetSD');    % V

% We compute the standard deviations in electrons for shot noise, PRNU and
% DSNU

% For noise we convert the voltage signal to electrons.  The mean is equal
% to the variance because the value is Poisson.  The variance has units of
% electrons squared.  We take the square root to obtain the SD, and this
% has units of electrons.
shotSD = sqrt(volts/convGain);           % Poisson std dev in electrons

% We specify the PRNU and DSNU levels as standard deviations with respect
% to volts.  So, we convert the volt SD to electron SD
prnuSD = gainSD.*(volts/convGain);       % SD of slope in v/(v/e) = e
dsnuSD = offsetSD/convGain;              % offset std dev in electrons

% Calculate signal power for each voltage level.
% The signal power has units of electrons squared. 
signalPower = (volts/convGain).^2;

% The noise power is the variance of the various noise sources.
% We add these.
noisePower = shotSD.^2 + readSD.^2 + dsnuSD.^2 + prnuSD.^2;

% Note: The PRNU contributes more noise at higher intensity levels, but in
% direct proportion to the signal intensity.  So, as signal goes up the SNR
% limit imposed by PRNU stays constant.

% We scale by 10 instead of 20 because we have squared the signal above and
% are using signal Power.
SNR = 10 * log10(signalPower./noisePower);

if nargout > 2
    noisePower = shotSD.^2;
    SNRshot = 10 * log10(signalPower./noisePower);
end
if nargout > 3
    if readSD == 0
        % SNRread = SNRshot + 20;
        SNRread = Inf;
    else
        noisePower = readSD.^2;
        SNRread = 10 * log10(signalPower./noisePower);
    end
end
if nargout > 4
    % Need to catch == 0 conditions
    if dsnuSD == 0
        % SNRdsnu = SNRshot + 20;
        SNRdsnu = Inf;
    else
        noisePower = dsnuSD.^2;
        SNRdsnu = 10 * log10(signalPower./noisePower);
    end
end
if nargout > 5
    if isequal(prnuSD,0)
        % SNRprnu = SNRshot + 20;
        SNRprnu = Inf;
    else
        noisePower = prnuSD.^2;
        SNRprnu = 10 * log10(signalPower./noisePower);
    end
end

return
