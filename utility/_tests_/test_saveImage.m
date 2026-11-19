function tests = test_saveImage
 tests = functiontests(localfunctions);
end

function testSavedPixels(testCase)
% Check exported pixel values instead of displaying and rereading images.
ieInit;
folder = tempname;
mkdir(folder);
cleanup = onCleanup(@() rmdir(folder,'s')); %#ok<NASGU>
scene = sceneCreate;
camera = cameraCompute(cameraCreate,scene);
file = sceneSaveImage(scene,fullfile(folder,'scene'));
expected = sceneShowImage(scene,-1,sceneGet(scene,'gamma'));
testCase.verifyEqual(imread(file),im2uint8(expected));
oi = cameraGet(camera,'oi');
file = oiSaveImage(oi,fullfile(folder,'oi'));
expected = oiShowImage(oi,-1,oiGet(oi,'gamma'));
testCase.verifyEqual(imread(file),im2uint8(expected));
ip = cameraGet(camera,'ip');
file = ipSaveImage(ip,fullfile(folder,'ip'),false,false);
expected = imageShowImage(ip,ipGet(ip,'display gamma'),true,0);
testCase.verifyEqual(imread(file),im2uint8(expected));
end
