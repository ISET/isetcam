function tests = test_ipDemosaicShift
 tests = functiontests(localfunctions);
end

function testLineLocation(testCase)
% Both demosaicers should keep a centered line at the same image column.
ieInit;
scene = sceneCreate('line ee');
camera = cameraCreate;
sensor = sensorSet(cameraGet(camera,'sensor'),'noise flag',0);
camera = cameraSet(camera,'sensor',sensor);
locations = zeros(2,3);
methods = {'bilinear','Laplacian'};
for ii = 1:2
    camera = cameraSet(camera,'ip demosaic method',methods{ii});
    camera = cameraCompute(camera,scene);
    ip = cameraGet(camera,'ip');
    rgb = ipGet(ip,'results');
    testCase.verifyTrue(all(isfinite(rgb(:))));
    profile = squeeze(sum(rgb,1));
    [~,locations(ii,:)] = max(profile,[],1);
end
testCase.verifyEqual(locations(1,:),locations(2,:),'AbsTol',1);
end
