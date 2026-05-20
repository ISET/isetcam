function tests = test_oiSmoke()
tests = functiontests(localfunctions);
end

function testOiWindowGammaSmoke(~)

ieInit;

scene = sceneCreate('gridlines',256);
scene = sceneSet(scene,'fov',1);
oi = oiCreate('wvf');
oi = oiCompute(oi,scene);

oiWindow(oi); pause(0.2);
oiSet(oi,'gamma',1);
oiSet(oi,'gamma',0.4); pause(0.5)
oiSet(oi,'gamma',1);

end

function testOiPadValueSmoke(~)

ieInit;

scene = sceneCreate('ringsrays');
oi = oiCreate('wvf');

oi = oiSet(oi,'compute method','opticsotf');
oi = oiCompute(oi,scene,'pad value','mean','crop',false);
oi = oiSet(oi,'name','Mean pad OTF');
oiWindow(oi);

oi = oiSet(oi,'compute method','opticsotf');
oi = oiCompute(oi,scene,'pad value','zero','crop',false);
oi = oiSet(oi,'name','Zero pad OTF');
oiWindow(oi);

oi = oiSet(oi,'compute method','opticspsf');
oi = oiCompute(oi,scene,'pad value','mean','crop',false);
oi = oiSet(oi,'name','Mean pad PSF');
oiWindow(oi);

oi = oiSet(oi,'compute method','opticspsf');
oi = oiCompute(oi,scene,'pad value','zero','crop',false);
oi = oiSet(oi,'name','Zero pad PSF');
oiWindow(oi);

end