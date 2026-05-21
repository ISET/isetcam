function tests = test_opticsAccessors()
tests = functiontests(localfunctions);
end

function testDefaultDiffractionLimitedOptics(~)
%% Default diffraction-limited optics structure and derived quantities

optics = opticsCreate('default');

assert(strcmp(opticsGet(optics,'type'),'optics'));
assert(strcmp(opticsGet(optics,'name'),'standard (1/4-inch)'));
assert(strcmp(opticsGet(optics,'model'),'diffractionlimited'));
assert(abs(opticsGet(optics,'fnumber') - 4) < 1e-12);

% The default focal length is set from the historical validation FOV and
% sensor diagonal in opticsCreate.
defaultFOV = 54.747093438872568;
sensorDiagonal = 0.004;
expectedFocalLength = (sensorDiagonal/2)/tand(defaultFOV/2);
assert(abs(opticsGet(optics,'focal length') - expectedFocalLength) < 1e-15);

expectedDiameter = expectedFocalLength/4;
assert(abs(opticsGet(optics,'aperture diameter') - expectedDiameter) < 1e-15);
assert(abs(opticsGet(optics,'aperture radius') - expectedDiameter/2) < 1e-15);
assert(abs(opticsGet(optics,'aperture area') - pi*(expectedDiameter/2)^2) < 1e-20);
assert(abs(opticsGet(optics,'numerical aperture') - 0.125) < 1e-12);
assert(abs(opticsGet(optics,'power') - 1/expectedFocalLength) < 1e-10);

imageWidthMM = opticsGet(optics,'image width',10,'mm');
expectedWidthMM = 2*expectedFocalLength*tand(10/2)*1000;
assert(abs(imageWidthMM - expectedWidthMM) < 1e-12);

transWave = opticsGet(optics,'transmittance wave');
transScale = opticsGet(optics,'transmittance');
assert(isequal(size(transWave),size(transScale)));
assert(all(transScale == 1));

end

function testSettersAndTransmittanceInterpolation(~)
%% Basic set/get paths and lens transmittance interpolation

optics = opticsCreate('default');

optics = opticsSet(optics,'name','unit-test optics');
assert(strcmp(opticsGet(optics,'name'),'unit-test optics'));

optics = opticsSet(optics,'model','shift invariant');
assert(strcmp(opticsGet(optics,'model'),'shiftinvariant'));

optics = opticsSet(optics,'fnumber',5.6);
optics = opticsSet(optics,'focal length',0.012);
assert(abs(opticsGet(optics,'fnumber') - 5.6) < 1e-12);
assert(abs(opticsGet(optics,'focal length','mm') - 12) < 1e-12);
assert(abs(opticsGet(optics,'aperture diameter','mm') - 12/5.6) < 1e-12);

optics = opticsSet(optics,'transmittance wave',[500 600 700]);
optics = opticsSet(optics,'transmittance scale',[0.8 0.9 1.0]);

interpScale = opticsGet(optics,'transmittance',[550 650]);
assert(max(abs(interpScale(:) - [0.85; 0.95])) < 1e-12);

extrapScale = opticsGet(optics,'transmittance',[450 750]);
assert(isequal(extrapScale(:),[1; 1]));

end

function testTransmittanceInputValidation(~)
%% Invalid lens transmittance inputs should fail explicitly

optics = opticsCreate('default');
optics = opticsSet(optics,'transmittance wave',[500 600 700]);

didError = false;
try
    opticsSet(optics,'transmittance scale',[0.8 1.2 1.0]);
catch
    didError = true;
end
assert(didError);

didError = false;
try
    opticsSet(optics,'transmittance scale',[0.8 0.9]);
catch
    didError = true;
end
assert(didError);

end

function testClearData(~)
%% Cached OTF and cos4th data are removed without changing core optics

optics = opticsCreate('shift invariant');
optics = opticsSet(optics,'cos4th data',ones(3,4));
optics = opticsSet(optics,'otf data',ones(3,4,2));

optics = opticsClearData(optics);

assert(isempty(opticsGet(optics,'cos4th data')));
assert(isempty(opticsGet(optics,'otf data')));
assert(strcmp(opticsGet(optics,'type'),'optics'));

end
