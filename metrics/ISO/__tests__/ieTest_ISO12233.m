function ieTest_ISO12233()
% ieTest_ISO12233
%
% Test the ISO 12233 calculations for SFR / MTF
%
% This function generates a synthetic slanted edge using ISETCam
% optics and sensor simulation, extracts the region, and passes it 
% to the ISO12233 base calculation functions. It asserts that the 
% MTF50 and Nyquist frequency remain stable against known golden values.
%
% The corresponding Python OralEye metrics test cross-validates
% against this exact algorithmic baseline.

    % Generate slanted edge and check golden MTF metrics
    scene = sceneCreate('slanted edge', 512);
    scene = sceneSet(scene,'fov',5);
    oi = oiCreate; oi = oiCompute(oi, scene);
    sensor = sensorCreate;
    sensor = sensorSetSizeToFOV(sensor, 1.5*sceneGet(scene,'fov'), oi);
    sensor = sensorCompute(sensor, oi);
    ip = ipCreate; ip = ipCompute(ip, sensor);

    masterRect = ISOFindSlantedBar(ip);
    barImage = vcGetROIData(ip,masterRect,'sensor space');
    r = masterRect(4)+1;
    c = masterRect(3)+1;
    barImage = reshape(barImage,r,c,[]);

    dx = sensorGet(sensor,'pixel width','mm');

    [mtfData, fitme, esf, h] = ISO12233(barImage, dx, [], 'none');

    % Golden value assertions
    expectedNyquist = 178.5714;
    expectedMtf50 = 74.2000;
    
    assert(abs(mtfData.nyquistf - expectedNyquist) < 1e-4, 'Nyquist freq mismatch');
    assert(abs(mtfData.mtf50 - expectedMtf50) < 1e-1, 'MTF50 mismatch');
    
    fprintf('ieTest_ISO12233 passed.\n');
end
