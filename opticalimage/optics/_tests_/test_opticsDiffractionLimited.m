function tests = test_opticsDiffractionLimited()
tests = functiontests(localfunctions);
end

function testAiryDiskRadiusAndDiameter(~)
%% Airy disk values follow the diffraction-limited formula

radiusUM = airyDisk(550,4,'units','um');
assert(abs(radiusUM - 1.22*4*550e-9*1e6) < 1e-12);

radiusFromMeters = airyDisk(550e-9,4,'units','um');
assert(abs(radiusFromMeters - radiusUM) < 1e-12);

diameterUM = airyDisk(550,4,'units','um','diameter',true);
assert(abs(diameterUM - 2*radiusUM) < 1e-12);

pinholeDeg = airyDisk(550,[],'units','deg','pupil diameter',1e-3);
assert(abs(pinholeDeg - asind(1.22*550e-9/1e-3)) < 1e-12);

end

function testDlCoreAnalyticValues(~)
%% dlCore returns the expected normalized OTF values

otfDC = dlCore(zeros(4,5),100);
assert(isequal(size(otfDC),[4 5]));
assert(max(abs(otfDC(:) - 1)) < 1e-12);

otfCutoff = dlCore(100*ones(4,5),100);
assert(max(abs(otfCutoff(:))) < 1e-12);

normalizedFrequency = 0.5;
expectedOTF = (2/pi)*(acos(normalizedFrequency) - ...
    normalizedFrequency*sqrt(1 - normalizedFrequency^2));
otfMidband = dlCore(50*ones(4,5),100);
assert(max(abs(otfMidband(:) - expectedOTF)) < 1e-12);

end

function testDlMTFWithExplicitFrequencySupport(~)
%% dlMTF can be called directly with an optics struct and explicit support

optics = opticsCreate('default');
fSupport = zeros(6,7,2);
[otf, returnedSupport, inCutoffFreq] = dlMTF(optics,fSupport,550,'mm');

assert(isequal(size(otf),[6 7]));
assert(max(abs(otf(:) - 1)) < 1e-12);
assert(isequal(returnedSupport,fSupport));

expectedCutoff = (1/opticsGet(optics,'fnumber'))/(550e-9)/1000;
assert(abs(inCutoffFreq - expectedCutoff) < 1e-6);

end

function testDlMTFMultipleWavelengths(~)
%% Cutoff frequency scales inversely with wavelength

optics = opticsCreate('default');
fSupport = zeros(3,3,2);
wave = [450 550 650];
[otf, ~, inCutoffFreq] = dlMTF(optics,fSupport,wave,'mm');

assert(isequal(size(otf),[3 3 3]));
assert(max(abs(otf(:) - 1)) < 1e-12);
assert(all(diff(inCutoffFreq) < 0));

expectedCutoff = (1/opticsGet(optics,'fnumber'))./(wave*1e-9)/1000;
assert(max(abs(inCutoffFreq(:) - expectedCutoff(:))) < 1e-6);

end
