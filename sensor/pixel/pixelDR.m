function DR = pixelDR(ISA,integrationTime)
% Calculate pixel dynamic range (dB)
%
%     DR = pixelDR(ISA,integrationTime)
%
%  Pixel dynamic range is t
%
%         20 log10 (voltageRange / noiseVoltage)
%
%  where:
%        voltageRange is (maxVoltage - darkVoltage)
%        noiseVoltage is sqrt(dkVoltageVariance + readNoiseVariance)
%
%  Note (1). This algorithm takes in the ISA, not just the PIXEL because
%  pixel DR depends on the integration time, which is attached to the ISA.
%
%
% Copyright ImagEval Consultants, LLC, 2003

if ieNotDefined('ISA'), ISA = vcGetObject('ISA'); end

pixel = sensorGet(ISA,'pixel');

if ieNotDefined('integrationTime')
    integrationTime = sensorGet(ISA,'integrationTime');
    if integrationTime == 0
        DR = [];
        return;
    end
end

% Define local variables
darkVoltage = pixelGet(pixel,'darkvolt');           % Volts/sec
readNoiseSD = pixelGet(pixel,'readNoiseVolts');     % Volts

% Calculate the total voltage rise in the dark.  The darkVoltage is per
% second, so we multiply by integration time
dkVoltageVariance = darkVoltage*integrationTime;

% Calculate the read noise variance
readNoiseVariance = readNoiseSD^2;

% The total noise standard deviation at the pixel is the sum of the read
% noise variance and the dark voltage variance.  The dark voltage variance
% is Poisson, so it is simply equal to the dark voltage
noiseSD = sqrt(dkVoltageVariance + readNoiseVariance);

% Now compute the workable voltage range.  This is the voltage swing minus
% the dark voltage
maxVoltage = pixelGet(pixel,'voltageswing') - darkVoltage*integrationTime;

% We can get 0 noiseSD if all noise is turned off.  So, we trap that case
% here.  Otherwise, DR is the voltage range divided by the noise level
% (computed in decibels).
if noiseSD == 0,  DR = Inf;
else, DR = 20 * log10(maxVoltage ./ noiseSD);
end

return;

%  An alternative form of the (same) calculation is below:
%
% maxCurrent = (q*wellCapacity/integrationTime) - darkCurrent;
% minCurrent = (q/integrationTime) * noiseSD;
%
% maxCharge = wellCapacity - (darkCurrent*integrationTime/q);
% minCharge = noiseSD;
% if maxCharge < 0 || minCharge == 0,  DR = [];
% else                   DR = 20 * log10(maxCharge ./ minCharge);
% end