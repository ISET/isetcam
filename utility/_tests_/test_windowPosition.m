function tests = test_windowPosition
 tests = functiontests(localfunctions);
end

function testObjectWindows(testCase)
% The suite's only object-window smoke test: one window for each stage.
ieInit;
existingFigures = findall(groot,'Type','figure');
cleanup = onCleanup(@() close(setdiff(findall(groot,'Type','figure'),existingFigures))); %#ok<NASGU>
scene = sceneCreate;
[~,scene] = chartCornerpoints(scene,true);
oi = oiCompute(oiCreate,scene);
sensor = sensorCreate;
sensor = sensorSet(sensor,'noise flag',0);
sensor = sensorCompute(sensor,oi);
ip = ipCompute(ipCreate,sensor);
objects = {scene,oi,sensor,ip};
apps = {sceneWindow(scene),oiWindow(oi),sensorWindow(sensor),ipWindow(ip)};
rect = [10 10 50 50];
for ii = 1:4
    testCase.verifyTrue(isvalid(apps{ii}));
    testCase.verifyTrue(isgraphics(apps{ii}.figure1,'figure'));
    h = ieDrawShape(objects{ii},'rectangle',rect);
    testCase.verifyEqual(h.Position,rect);
    delete(h);
end
% Gamma is an app property, so exercise it while the scene window exists.
sceneSet(scene,'gamma',0.5);
testCase.verifyEqual(sceneGet(scene,'gamma'),0.5);
sceneSet(scene,'gamma',1);
center = ipGet(ip,'center');
radius = center(1)/4;
h = ieDrawShape(ip,'circle',center(1:2),radius);
distance = hypot(h.XData-center(2),h.YData-center(1));
testCase.verifyEqual(distance,radius*ones(size(distance)),'AbsTol',1e-10);
delete(h);
macbethDrawRects(scene,'on');
macbethDrawRects(scene,'off');
[positions,~] = ieWindowsGet(false);
for ii = 1:4
    testCase.verifyEqual(positions{ii+1},apps{ii}.figure1.Position);
end
ieWindowsSet(positions);
after = ieWindowsGet(false);
for ii = 2:5
    testCase.verifyEqual(after{ii},positions{ii},'AbsTol',1);
end
end
