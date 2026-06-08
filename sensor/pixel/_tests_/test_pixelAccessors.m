function tests = test_pixelAccessors()
tests = functiontests(localfunctions);
end

function testDefaultPixelStructure(~)
%% Default APS pixel structure and derived quantities

pixel = pixelCreate('default');

assert(strcmp(pixel.type,'pixel'));
assert(strcmp(pixel.name,'aps'));

assert(abs(pixelGet(pixel,'width','um') - 2.8) < 1e-12);
assert(abs(pixelGet(pixel,'height','um') - 2.8) < 1e-12);
assert(abs(pixelGet(pixel,'area') - (2.8e-6)^2) < 1e-24);
assert(isequal(pixelGet(pixel,'size','um'),[2.8 2.8]));
assert(isequal(pixelGet(pixel,'xy spacing','um'),[2.8 2.8]));

assert(abs(pixelGet(pixel,'fill factor') - 0.75) < 1e-12);
assert(abs(pixelGet(pixel,'pd width','um') - sqrt(2.8^2*0.75)) < 1e-12);
assert(abs(pixelGet(pixel,'pd height','um') - sqrt(2.8^2*0.75)) < 1e-12);

expectedPdPos = (pixelGet(pixel,'width') - pixelGet(pixel,'pd width'))/2;
assert(abs(pixelGet(pixel,'pd x pos') - expectedPdPos) < 1e-18);
assert(abs(pixelGet(pixel,'pd y pos') - expectedPdPos) < 1e-18);

assert(pixelGet(pixel,'conversion gain') == 1e-4);
assert(pixelGet(pixel,'voltage swing') == 1);
assert(pixelGet(pixel,'well capacity') == 1e4);
assert(pixelGet(pixel,'dark voltage') == 1e-3);
assert(pixelGet(pixel,'dark electrons') == 10);
assert(pixelGet(pixel,'read noise volts') == 1e-3);
assert(pixelGet(pixel,'read noise electrons') == 10);
assert(pixelGet(pixel,'read noise millivolts') == 1);

assert(pixelGet(pixel,'nwave') == 31);
assert(pixelGet(pixel,'binwidth') == 10);
assert(all(pixelGet(pixel,'spectral qe') == 1));

end

function testSettersPreserveAndChangeFillFactor(~)
%% Pixel size setters distinguish raw size from constant-fill-factor size

pixel = pixelCreate('default');
initialFillFactor = pixelGet(pixel,'fill factor');

pixel = pixelSet(pixel,'size constant fill factor',[4 5]*1e-6);
assert(isequal(pixelGet(pixel,'size'),[5 4]*1e-6));
assert(abs(pixelGet(pixel,'fill factor') - initialFillFactor) < 1e-12);

pixel = pixelSet(pixel,'size',[8 10]*1e-6);
assert(isequal(pixelGet(pixel,'size'),[10 8]*1e-6));
assert(pixelGet(pixel,'fill factor') < initialFillFactor);

pixel = pixelSet(pixel,'fill factor',0.5);
assert(abs(pixelGet(pixel,'fill factor') - 0.5) < 1e-12);

pixel = pixelSet(pixel,'width gap',0.2e-6);
pixel = pixelSet(pixel,'height gap',0.3e-6);
assert(abs(pixelGet(pixel,'deltax') - 8.2e-6) < 1e-18);
assert(abs(pixelGet(pixel,'deltay') - 10.3e-6) < 1e-18);

end

function testElectricalAndSpectralSetters(~)
%% Electrical and spectral setters update derived quantities

wave = (500:50:650)';
pixel = pixelCreate('default',wave);

pixel = pixelSet(pixel,'conversion gain',2e-4);
pixel = pixelSet(pixel,'voltage swing',1.2);
pixel = pixelSet(pixel,'dark voltage',4e-3);
pixel = pixelSet(pixel,'read noise electrons',12);
pixel = pixelSet(pixel,'spectral qe',[0.2 0.4 0.6 0.8]');

assert(pixelGet(pixel,'conversion gain') == 2e-4);
assert(pixelGet(pixel,'voltage swing') == 1.2);
assert(abs(pixelGet(pixel,'well capacity') - 6000) < 1e-9);
assert(abs(pixelGet(pixel,'dark electrons') - 20) < 1e-12);
assert(abs(pixelGet(pixel,'read noise volts') - 2.4e-3) < 1e-15);
assert(pixelGet(pixel,'read noise electrons') == 12);
assert(isequal(pixelGet(pixel,'wave'),wave));
assert(isequal(pixelGet(pixel,'spectral qe'),[0.2 0.4 0.6 0.8]'));

sr = pixelGet(pixel,'spectral sr');
q = vcConstants('q');
h = vcConstants('h');
c = vcConstants('c');
expectedSR = (wave(:)*1e-9*q)/(h*c) .* pixelGet(pixel,'spectral qe');
assert(max(abs(sr - expectedSR)) < 1e-12);

didError = false;
try
    pixelSet(pixel,'spectral qe',[0.1 0.2]);
catch
    didError = true;
end
assert(didError);

end

function testPhotodetectorPositioning(~)
%% Photodetector placement helpers set expected geometry

pixel = pixelCreate('default');
pixel = pixelSet(pixel,'pd size',[1.0 1.2]*1e-6);

pixel = pixelPositionPD(pixel,'center');
assert(abs(pixelGet(pixel,'pd x pos') - (pixelGet(pixel,'width') - pixelGet(pixel,'pd width'))/2) < 1e-18);
assert(abs(pixelGet(pixel,'pd y pos') - (pixelGet(pixel,'height') - pixelGet(pixel,'pd height'))/2) < 1e-18);

pixel = pixelPositionPD(pixel,'corner');
assert(pixelGet(pixel,'pd x pos') == 0);
assert(pixelGet(pixel,'pd y pos') == 0);

didError = false;
try
    pixelPositionPD(pixel,'outside');
catch
    didError = true;
end
assert(didError);

end

function testOtherPixelTypes(~)
%% Ideal and cone pixel constructors expose expected type-specific geometry

ideal = pixelCreate('ideal',400:10:700,1.5e-6);
assert(abs(pixelGet(ideal,'fill factor') - 1) < 1e-12);
assert(pixelGet(ideal,'dark voltage') == 0);
assert(pixelGet(ideal,'read noise volts') == 0);
assert(pixelGet(ideal,'voltage swing') == 1e6);

human = pixelCreate('human');
assert(strcmp(human.name,'humancone'));
assert(abs(pixelGet(human,'width','um') - 2) < 1e-12);
assert(abs(pixelGet(human,'fill factor') - 1) < 1e-12);

mouse = pixelCreate('mouse');
assert(strcmp(mouse.name,'mousecone'));
assert(abs(pixelGet(mouse,'width','um') - 9) < 1e-12);
assert(abs(pixelGet(mouse,'pd width','um') - 2) < 1e-12);

end
