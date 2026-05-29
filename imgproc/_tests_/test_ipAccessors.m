function tests = test_ipAccessors()
tests = functiontests(localfunctions);
end

function testDefaultIpStructure(~)
%% Default image processor exposes expected structure and processing methods

ip = ipCreate('unit test ip');

assert(strcmp(ipGet(ip,'type'),'vcimage'));
assert(strcmp(ipGet(ip,'name'),'unit test ip'));
assert(strcmp(ipGet(ip,'demosaic method'),'bilinear'));
assert(strcmp(ipGet(ip,'illuminant correction method'),'none'));
assert(strcmp(ipGet(ip,'sensor conversion method'),'MCC optimized'));
assert(strcmp(ipGet(ip,'transform method'),'adaptive'));
assert(strcmp(ipGet(ip,'internal cs'),'XYZ'));

wave = ipGet(ip,'wave');
assert(isvector(wave));
assert(ipGet(ip,'nwave') == numel(wave));
assert(ipGet(ip,'binwidth') == wave(2) - wave(1));
assert(~isempty(ipGet(ip,'display')));
assert(ipGet(ip,'scale display output') == true);

end

function testDataAccessorsAndDerivedGeometry(~)
%% Input and result data accessors report stable image geometry

ip = ipCreate;
sensorInput = reshape(1:20,4,5);
linearDisplay = cat(3,0.1*ones(4,5),0.2*ones(4,5),0.3*ones(4,5));

ip = ipSet(ip,'input',sensorInput);
ip = ipSet(ip,'result',linearDisplay);
ip = ipSet(ip,'datamax',1023);

assert(isequal(ipGet(ip,'input'),sensorInput));
assert(isequal(ipGet(ip,'input size'),[4 5]));
assert(ipGet(ip,'row') == 4);
assert(ipGet(ip,'col') == 5);

assert(isequal(ipGet(ip,'result'),linearDisplay));
assert(isequal(ipGet(ip,'result size'),[4 5 3]));
assert(isequal(ipGet(ip,'result primary',2),linearDisplay(:,:,2)));
assert(abs(ipGet(ip,'result max') - 0.3) < 1e-12);
assert(ipGet(ip,'maximum sensor value') == 1023);

center = ipGet(ip,'center');
grid = ipGet(ip,'image grid');
distance = ipGet(ip,'distance2center');
angle = ipGet(ip,'angle');

assert(isequal(center,[2.5 3]));
assert(isequal(size(grid{1}),[4 5]));
assert(isequal(size(grid{2}),[4 5]));
assert(isequal(size(distance),[4 5]));
assert(isequal(size(angle),[4 5]));
assert(abs(distance(2,3) - 0.5) < 1e-12);

ip = ipClearData(ip);
assert(isempty(ipGet(ip,'data')));

end

function testProcessingMethodAndTransformAccessors(~)
%% Pipeline method and transform setters round-trip through ipGet

ip = ipCreate;

ip = ipSet(ip,'demosaic method','Nearest Neighbor');
ip = ipSet(ip,'illuminant correction method','Gray World');
ip = ipSet(ip,'sensor conversion method','None');
ip = ipSet(ip,'transform method','Current');
ip = ipSet(ip,'internal cs','sensor');
ip = ipSet(ip,'scale display output',false);

assert(strcmp(ipGet(ip,'demosaic method'),'nearest neighbor'));
assert(strcmp(ipGet(ip,'illuminant correction method'),'gray world'));
assert(strcmp(ipGet(ip,'sensor conversion method'),'None'));
assert(strcmp(ipGet(ip,'transform method'),'current'));
assert(strcmp(ipGet(ip,'internal cs'),'sensor'));
assert(ipGet(ip,'scale display output') == false);

sensorCorrection = [1 0 0; 0 2 0; 0 0 3];
illuminantCorrection = [1 0.1 0; 0 1 0.2; 0 0 1];
displayTransform = [0.9 0 0; 0 0.8 0; 0 0 0.7];

ip = ipSet(ip,'sensor conversion matrix',sensorCorrection);
ip = ipSet(ip,'illuminant correction matrix',illuminantCorrection);
ip = ipSet(ip,'ics2display transform',displayTransform);

assert(isequal(ipGet(ip,'sensor conversion matrix'),sensorCorrection));
assert(isequal(ipGet(ip,'illuminant correction matrix'),illuminantCorrection));
assert(isequal(ipGet(ip,'ics2display transform'),displayTransform));

expectedProduct = sensorCorrection*illuminantCorrection*displayTransform;
assert(max(abs(ipGet(ip,'prodT') - expectedProduct),[],'all') < 1e-12);

eachTransform = ipGet(ip,'each transform');
assert(isequal(eachTransform{1},sensorCorrection));
assert(isequal(eachTransform{2},illuminantCorrection));
assert(isequal(eachTransform{3},displayTransform));

end
