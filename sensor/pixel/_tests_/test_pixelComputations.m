function tests = test_pixelComputations()
tests = functiontests(localfunctions);
end

function testPixelWellCapacityInterpolation(~)
%% Full-well capacity helper interpolates the stored lookup table

[electrons, wellCapacity] = iePixelWellCapacity(2);

assert(isequal(size(wellCapacity,2),2));
assert(size(wellCapacity,1) > 10);
assert(all(diff(wellCapacity(:,1)) > 0));
assert(abs(electrons/1.72269787757456e+04 - 1) < 1e-10);

electrons = iePixelWellCapacity(4.2);
assert(abs(electrons/3.47225250957828e+04 - 1) < 1e-10);

[electrons, wellCapacityOnly] = iePixelWellCapacity([]);
assert(isempty(electrons));
assert(isequal(wellCapacityOnly,wellCapacity));

end

function testPixelSNRFormula(~)
%% Pixel SNR matches the closed-form shot-plus-read-noise calculation

sensor = sensorCreate('monochrome');
pixel = sensorGet(sensor,'pixel');
volts = [1e-4 1e-2 1];

[snr, returnedVolts, shotSNR, readSNR] = pixelSNR(sensor,volts);

conversionGain = pixelGet(pixel,'conversion gain');
readSD = pixelGet(pixel,'read noise electrons');
meanElectrons = volts/conversionGain;
signalPower = meanElectrons.^2;
shotSD = sqrt(meanElectrons);
expectedSNR = 10*log10(signalPower./(readSD.^2 + shotSD.^2));
expectedShotSNR = 10*log10(signalPower./(shotSD.^2));
expectedReadSNR = 10*log10(signalPower./(readSD.^2));

assert(isequal(returnedVolts,volts));
assert(max(abs(snr - expectedSNR)) < 1e-12);
assert(max(abs(shotSNR - expectedShotSNR)) < 1e-12);
assert(max(abs(readSNR - expectedReadSNR)) < 1e-12);

end

function testPixelDynamicRange(~)
%% Pixel dynamic range follows voltage swing, dark voltage, and read noise

sensor = sensorCreate('monochrome');
integrationTime = 0.01;
pixel = sensorGet(sensor,'pixel');

dr = pixelDR(sensor,integrationTime);

darkVoltage = pixelGet(pixel,'dark voltage');
readNoiseSD = pixelGet(pixel,'read noise volts');
noiseSD = sqrt(darkVoltage*integrationTime + readNoiseSD^2);
maxVoltage = pixelGet(pixel,'voltage swing') - darkVoltage*integrationTime;
expectedDR = 20*log10(maxVoltage/noiseSD);

assert(abs(dr - expectedDR) < 1e-12);

pixel = pixelSet(pixel,'dark voltage',0);
pixel = pixelSet(pixel,'read noise volts',0);
sensor = sensorSet(sensor,'pixel',pixel);
assert(isinf(pixelDR(sensor,integrationTime)));

end

function testPixelVperLuxSec(~)
%% Photometric sensitivity helper returns self-consistent monochrome values

sensor = sensorCreate('monochrome');
[voltsPerLuxSec,luxsec,meanVolts,voltsPerAntiLuxSec,antiLuxsec] = ...
    pixelVperLuxSec(sensor);

assert(isscalar(voltsPerLuxSec));
assert(isscalar(meanVolts));
assert(isfinite(voltsPerLuxSec));
assert(luxsec > 0);
assert(meanVolts > 0);
assert(abs(voltsPerLuxSec - meanVolts/luxsec) < 1e-12);

if antiLuxsec == 0
    assert(isinf(voltsPerAntiLuxSec));
else
    assert(abs(voltsPerAntiLuxSec - meanVolts/antiLuxsec) < 1e-12);
end

end
