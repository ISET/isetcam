function tests = test_ipDemosaic()
tests = functiontests(localfunctions);
end

function testBayerDemosaicKnownConstantChannels(~)
%% Bayer demosaicking preserves known channel constants

sensor = sensorCreate('bayer-rggb');
mosaic = localChannelConstantMosaic(sensor,8,8,[10 20 30]);

ip = ipCreate;
ip = ipSet(ip,'input',mosaic);

methods = {'bilinear','nearest neighbor'};
for ii = 1:numel(methods)
    ip = ipSet(ip,'demosaic method',methods{ii});
    rgb = Demosaic(ip,sensor);

    assert(isequal(size(rgb),[8 8 3]));
    assert(all(isfinite(rgb(:))));
    assert(max(abs(rgb(:,:,1) - 10),[],'all') < 1e-12);
    assert(max(abs(rgb(:,:,2) - 20),[],'all') < 1e-12);
    assert(max(abs(rgb(:,:,3) - 30),[],'all') < 1e-12);
end

end

function testDemosaicAcceptsAlreadyPlanarSensorChannels(~)
%% Sparse RGB-format sensor input bypasses plane2rgb and demosaics correctly

sensor = sensorCreate('bayer-rggb');
mosaic = localChannelConstantMosaic(sensor,8,8,[10 20 30]);
rgbInput = plane2rgb(mosaic,sensor,0);

ip = ipCreate;
ip = ipSet(ip,'input',rgbInput);
ip = ipSet(ip,'demosaic method','bilinear');

rgb = Demosaic(ip,sensor);

assert(isequal(size(rgb),[8 8 3]));
assert(max(abs(rgb(:,:,1) - 10),[],'all') < 1e-12);
assert(max(abs(rgb(:,:,2) - 20),[],'all') < 1e-12);
assert(max(abs(rgb(:,:,3) - 30),[],'all') < 1e-12);

end

function testSensorArrayBypassesDemosaic(~)
%% Sensor arrays are stacked directly without spatial demosaicking

sensors(1) = sensorCreate('monochrome');
sensors(2) = sensorCreate('monochrome');
sensors(3) = sensorCreate('monochrome');

for ii = 1:numel(sensors)
    sensors(ii) = sensorSet(sensors(ii),'volts',ii*ones(3,4));
end

ip = ipCreate;
demosaiced = Demosaic(ip,sensors);

assert(isequal(size(demosaiced),[3 4 3]));
for ii = 1:numel(sensors)
    assert(max(abs(demosaiced(:,:,ii) - ii),[],'all') < 1e-12);
end

end

function testUnknownDemosaicMethodErrors(~)
%% Unsupported method names fail before returning invalid image data

sensor = sensorCreate('bayer-rggb');
ip = ipCreate;
ip = ipSet(ip,'input',ones(4,4));
ip = ipSet(ip,'demosaic method','not a method');

didError = false;
try
    Demosaic(ip,sensor);
catch
    didError = true;
end

assert(didError);

end

function mosaic = localChannelConstantMosaic(sensor,nRows,nCols,channelValues)
%% Build a CFA plane whose sampled locations have known channel constants.

pattern = sensorGet(sensor,'pattern');
patternRows = size(pattern,1);
patternCols = size(pattern,2);
mosaic = zeros(nRows,nCols);

for rr = 1:nRows
    for cc = 1:nCols
        channelIndex = pattern(mod(rr - 1,patternRows) + 1, ...
            mod(cc - 1,patternCols) + 1);
        mosaic(rr,cc) = channelValues(channelIndex);
    end
end

end
