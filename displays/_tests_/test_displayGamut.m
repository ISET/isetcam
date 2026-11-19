function tests = test_displayGamut
tests = functiontests(localfunctions);
end

function testXYZGeometry(testCase)
d = displayCreate('LCD-Apple');
[data,g] = displayGamut(d,'space','xyz','plot',false);
testCase.verifyEmpty(g);
testCase.verifySize(data.corners,[8 3]);
testCase.verifyEqual(min(data.vertices,[],1),[0 0 0],'AbsTol',1e-12);
testCase.verifyEqual(max(data.vertices,[],1), ...
    displayGet(d,'white xyz'),'AbsTol',1e-9);
[~,volume] = convhulln(data.vertices);
testCase.verifyEqual(volume,abs(det(displayGet(d,'rgb2xyz'))),'RelTol',1e-10);
testCase.verifyGreaterThanOrEqual(data.rgb,0);
testCase.verifyLessThanOrEqual(data.rgb,1);
% Refinement must keep all triangles on the physical RGB cube boundary.
linear = data.vertices / displayGet(d,'rgb2xyz');
testCase.verifyLessThan(min(min(abs(linear),abs(linear-1)),[],2),1e-10);
end

function testChromaticityAndScaling(testCase)
d = displayCreate('LCD-Apple');
data = displayGamut(d,'plot',false);
xy = chromaticity(displayGet(d,'rgb2xyz'));
testCase.verifyEqual(data.xy(1,:),data.xy(end,:));
testCase.verifyEqual(sortrows(data.xy(1:end-1,:)),sortrows(xy),'AbsTol',1e-12);
brighter = displaySet(d,'spd',2*displayGet(d,'spd'));
scaled = displayGamut(brighter,'plot',false);
testCase.verifyEqual(scaled.xy,data.xy,'AbsTol',1e-12);
a = displayGamut(d,'space','xyz','plot',false);
b = displayGamut(brighter,'space','xyz','plot',false);
testCase.verifyEqual(sortrows(b.corners),2*sortrows(a.corners),'AbsTol',1e-9);
end

function testExtraAndZeroPrimaries(testCase)
d = displayCreate('LCD-Apple');
spd = displayGet(d,'spd');
d = displaySet(d,'spd',[spd,spd(:,1)+spd(:,2),zeros(size(spd,1),1)]);
data = displayGamut(d,'space','xyz','plot',false);
testCase.verifyEqual(max(data.vertices,[],1), ...
    displayGet(d,'white xyz'),'AbsTol',1e-9);
expected = chromaticity(displayGet(d,'rgb2xyz'));
testCase.verifyTrue(all(inpolygon(expected(1:4,1),expected(1:4,2), ...
    data.xy(:,1),data.xy(:,2))));
end

function testDegenerateGamut(testCase)
d = displayCreate('equalenergy');
data = displayGamut(d,'plot',false);
testCase.verifyTrue(all(isfinite(data.xy(:))));
testCase.verifyError(@() displayGamut(d,'space','xyz','plot',false), ...
    'displayGamut:DegenerateGamut');
end

function testPlotGatewayGeometry(testCase)
d = displayCreate('LCD-Apple.mat');
expected = displayGamut(d,'plot',false);
for mode = {'gamut','gamut2d'}
    [data,g] = displayPlot(d,mode{1},'plot',false);
    testCase.verifyEmpty(g);
    testCase.verifyEqual(data,expected);
end
expected = displayGamut(d,'space','xyz','subdivisions',1,'plot',false);
[data,g] = displayPlot(d,'gamut3d','subdivisions',1,'plot',false);
testCase.verifyEmpty(g);
testCase.verifyEqual(data,expected);
end

function testRefinementGeometry(testCase)
d = displayCreate('LCD-Apple.mat');
a = displayGamut(d,'space','xyz','subdivisions',0,'plot',false);
b = displayGamut(d,'space','xyz','subdivisions',2,'plot',false);
testCase.verifyEqual(size(b.faces,1),16*size(a.faces,1));
% Signed tetrahedral volumes test the returned surface, including winding.
testCase.verifyEqual(surfaceVolume(a),surfaceVolume(b),'RelTol',1e-12);
testCase.verifyEqual(surfaceVolume(b),abs(det(displayGet(d,'rgb2xyz'))), ...
    'RelTol',1e-12);
end

function volume = surfaceVolume(data)
a = data.vertices(data.faces(:,1),:);
b = data.vertices(data.faces(:,2),:);
c = data.vertices(data.faces(:,3),:);
volume = abs(sum(dot(a,cross(b,c,2),2))/6);
end
