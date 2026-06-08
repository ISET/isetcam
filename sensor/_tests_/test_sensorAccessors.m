function tests = test_sensorAccessors()
tests = functiontests(localfunctions);
end

function testDefaultBayerSensorStructure(~)
%% Default Bayer sensor structure and derived quantities

sensor = sensorCreate('bayer-rggb');

assert(strcmp(sensorGet(sensor,'type'),'sensor'));
assert(isequal(sensorGet(sensor,'size'),sensorFormats('qqcif')));
assert(isequal(sensorGet(sensor,'pattern'),[1 2; 2 3]));
assert(isequal(sensorGet(sensor,'cfa size'),[2 2]));
assert(sensorGet(sensor,'unit block rows') == 2);
assert(sensorGet(sensor,'unit block cols') == 2);

assert(sensorGet(sensor,'nfilters') == 3);
assert(strcmp(sensorGet(sensor,'filter color letters'),'rgb'));
assert(isequal(sensorGet(sensor,'pattern colors'),['r' 'g'; 'g' 'b']));
assert(isequal(sensorGet(sensor,'filter plot colors'),'rgb'));

assert(abs(sensorGet(sensor,'pixel width','um') - 2.8) < 1e-12);
assert(abs(sensorGet(sensor,'pixel height','um') - 2.8) < 1e-12);
assert(abs(sensorGet(sensor,'width','um') - 88*2.8) < 1e-10);
assert(abs(sensorGet(sensor,'height','um') - 72*2.8) < 1e-10);
assert(max(abs(sensorGet(sensor,'dimension','um') - [72 88]*2.8)) < 1e-10);

assert(strcmp(sensorGet(sensor,'quantization method'),'analog'));
assert(isempty(sensorGet(sensor,'nbits')));
assert(sensorGet(sensor,'noise flag') == 2);
assert(sensorGet(sensor,'reuse noise') == 0);
assert(sensorGet(sensor,'auto exposure') == 1);
assert(sensorGet(sensor,'cds') == 0);

end

function testSettersAndDataClearing(~)
%% Sensor setters preserve CFA constraints and clear stale data

sensor = sensorCreate('bayer-rggb');

sensor = sensorSet(sensor,'name','unit-test sensor');
assert(strcmp(sensorGet(sensor,'name'),'unit-test sensor'));

sensor = sensorSet(sensor,'size',[75 89]);
assert(isequal(sensorGet(sensor,'size'),[74 88]));

sensor = sensorSet(sensor,'volts',reshape(1:35,5,7));
assert(isequal(sensorGet(sensor,'size'),[5 7]));
assert(isequal(sensorGet(sensor,'volts'),reshape(1:35,5,7)));

sensor = sensorSet(sensor,'size',[32 34]);
assert(isequal(sensorGet(sensor,'size'),[32 34]));
assert(isempty(sensorGet(sensor,'volts')));

sensor = sensorSet(sensor,'pattern and size',[1 2 3; 3 2 1; 1 3 2]);
assert(isequal(sensorGet(sensor,'pattern'),[1 2 3; 3 2 1; 1 3 2]));
assert(isequal(sensorGet(sensor,'size'),[33 36]));

sensor = sensorSet(sensor,'dsnu level',0.01);
sensor = sensorSet(sensor,'prnu level',0.02);
assert(isequal(sensorGet(sensor,'fpn parameters'),[0.01 0.02]));

sensor = sensorSet(sensor,'column fpn',[0.003 0.004]);
assert(isequal(sensorGet(sensor,'column fpn'),[0.003 0.004]));
assert(sensorGet(sensor,'column dsnu') == 0.003);
assert(sensorGet(sensor,'column prnu') == 0.004);

end

function testWavelengthSetInterpolatesDependentSpectra(~)
%% Changing sensor wavelengths keeps pixel and filters synchronized

sensor = sensorCreate('bayer-rggb');
wave = [450 550 650]';

sensor = sensorSet(sensor,'wave',wave);

assert(isequal(sensorGet(sensor,'wave'),wave));
assert(isequal(pixelGet(sensorGet(sensor,'pixel'),'wave'),wave));
assert(sensorGet(sensor,'nwave') == numel(wave));
assert(sensorGet(sensor,'binwidth') == 100);

filterSpectra = sensorGet(sensor,'filter spectra');
irFilter = sensorGet(sensor,'ir filter');
pdQE = pixelGet(sensorGet(sensor,'pixel'),'spectral qe');

assert(isequal(size(filterSpectra),[numel(wave) sensorGet(sensor,'nfilters')]));
assert(isequal(size(irFilter),[numel(wave) 1]));
assert(isequal(size(pdQE),[numel(wave) 1]));
assert(all(irFilter == 1));
assert(all(pdQE == 1));

end

function testSensorGeometryAndFOVSizing(~)
%% Sensor geometry accessors and FOV sizing stay internally consistent

sensor = sensorCreate('bayer-rggb');
sensor = sensorSet(sensor,'size',[20 30]);
oi = oiCreate;

support = sensorGet(sensor,'spatial support','um');
assert(numel(support.y) == 20);
assert(numel(support.x) == 30);
assert(abs(support.y(1) + support.y(end)) < 1e-12);
assert(abs(support.x(1) + support.x(end)) < 1e-12);

targetFOV = 5;
sensor = sensorSet(sensor,'fov',targetFOV,oi);

sz = sensorGet(sensor,'size');
cfaSize = sensorGet(sensor,'cfa size');
assert(all(rem(sz,cfaSize) == 0));
assert(sensorGet(sensor,'width') > 0);
assert(sensorGet(sensor,'height') > 0);

actualFOV = sensorGet(sensor,'fov',1e6,oi);
assert(abs(actualFOV - targetFOV) < sensorGet(sensor,'h deg per pixel',oi));

end

function testExposureNoiseAndQuantizationSetters(~)
%% Exposure, noise, and quantization aliases map to stable stored values

sensor = sensorCreate('bayer-rggb');

sensor = sensorSet(sensor,'exposure time',[0.01 0.04]);
assert(isequal(sensorGet(sensor,'exposure time'),[0.01 0.04]));
assert(strcmp(sensorGet(sensor,'exposure method'),'bracketedExposure'));
assert(abs(sensorGet(sensor,'central exposure') - 0.02) < 1e-12);
assert(sensorGet(sensor,'auto exposure') == 0);

sensor = sensorSet(sensor,'auto exposure','on');
assert(sensorGet(sensor,'auto exposure') == 1);
assert(sensorGet(sensor,'exposure time') == 0);

sensor = sensorSet(sensor,'noise flag','ideal');
assert(sensorGet(sensor,'noise flag') == -1);
sensor = sensorSet(sensor,'noise flag','photononly');
assert(sensorGet(sensor,'noise flag') == -2);
sensor = sensorSet(sensor,'noise flag','all');
assert(sensorGet(sensor,'noise flag') == 2);

sensor = sensorSet(sensor,'quantization method','10 bit');
assert(strcmp(sensorGet(sensor,'quantization method'),'linear'));
assert(sensorGet(sensor,'nbits') == 10);

sensor = sensorSet(sensor,'analog gain',4);
sensor = sensorSet(sensor,'analog offset',0.125);
assert(sensorGet(sensor,'analog gain') == 4);
assert(sensorGet(sensor,'analog offset') == 0.125);

sensor = sensorSet(sensor,'response type','log');
assert(strcmp(sensorGet(sensor,'response type'),'log'));

didError = false;
try
    sensorSet(sensor,'response type','gamma');
catch
    didError = true;
end
assert(didError);

end
