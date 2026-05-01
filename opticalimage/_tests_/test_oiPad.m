function tests = test_oiPad()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% v_oiPad
%
% Validate the oiPad function in two ways.
% 
% First, we check that padding does not change the sample spacing,
% just the row/col size of the oi data.  This is tested for the
% diffraction limited, shift-invariant and ray trace models.
%
% Second, we compute with different pad values at the border (zero,
% mean, border).  We test this 'padvalue' operation for both the
% opticspsf and opticsotf paths.
%

%%
ieInit

%%  Test scene - decent but low resolution
s = sceneCreate('slanted bar',96);
s = sceneSet(s,'fov',1);
ieAddObject(s);

%% Make DL oi for testing
oi = oiCreate('diffraction limited');
oi = oiCompute(oi,s);
oiGet(oi,'fov');
baseSpacing = oiGet(oi,'sample spacing');

%% Verify that padding does not change the sample spacing
for padding = 10:10:100
    oip = oiPad(oi,[padding,padding]);
    % oiGet(oip,'fov')
    newSpacing = oiGet(oip,'sample spacing');
    assert(max(abs(newSpacing - baseSpacing)) < 1e-10)
end
% disp('v_oiPad succeeds for diffraction limited');

%% Make SIL oi for testing
oi = oiCreate('shift invariant');
oi = oiCompute(oi,s);
oiGet(oi,'fov');
baseSpacing = oiGet(oi,'sample spacing');
sz = oiGet(oi,'size');
% oiWindow(oi);

%% Verify that padding does not change the sample spacing
for padding = 10:10:100
    oip = oiPad(oi,[padding,padding]);
    % oiGet(oip,'fov')
    newSpacing = oiGet(oip,'sample spacing');
    assert(max(abs(newSpacing - baseSpacing)) < 1e-10)
end
% disp('v_oiPad succeeds for shift invariant');
%%  Now check for the ray trace oi case, which failed at one time

% Fewer wavelengths for speed
s = sceneSet(s,'wave',400:100:700);
s = sceneSet(s,'distance',2);   % Matches the lens
ieAddObject(s);

oi = oiCreate('raytrace');
oi = oiCompute(oi,s);
baseSpacing = oiGet(oi,'sample spacing');

%%
for padding = 10:10:100
    oip = oiPad(oi,[padding,padding]);
    newSpacing = oiGet(oip,'sample spacing');
    assert(max(abs(newSpacing - baseSpacing)) < 1e-10)
end
disp('v_oiPad succeeds for ray trace');
ieDeleteObject(s);

%%  Different pad values for OTF and PSF compute paths

scene = sceneCreate('ringsrays');
oi = oiCreate('wvf');

% Set opticsotf path.
oi = oiSet(oi,'compute method','opticsotf');
oi = oiCompute(oi,scene,'pad value','mean','crop',false);
oi = oiSet(oi,'name','Mean pad OTF');
oiWindow(oi);

%
oi = oiSet(oi,'compute method','opticsotf');
oi = oiCompute(oi,scene,'pad value','zero','crop',false);
oi = oiSet(oi,'name','Zero pad OTF');
oiWindow(oi);

% Set PSF path
oi = oiSet(oi,'compute method','opticspsf');
oi = oiCompute(oi,scene,'pad value','mean','crop',false);
oi = oiSet(oi,'name','Mean pad PSF');
oiWindow(oi);

%
oi = oiSet(oi,'compute method','opticspsf');
oi = oiCompute(oi,scene,'pad value','zero','crop',false);
oi = oiSet(oi,'name','Zero pad PSF');
oiWindow(oi);

%% END
end
