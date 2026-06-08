function tests = test_sensorSplitpixel()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
% v_icam_splitpixel

% Not yet implemented

ieInit;
return;

%% Here is a high dynamic range test chart

% The parameters are set to match a small split pixel sensor below
scene = sceneCreate('hdr chart','cols per level',12,'n levels',8,'d range',10^5);
scene = sceneSet(scene,'fov',8); 

oi = oiCreate('wvf'); 
oi = oiCompute(oi,scene,'crop',true);
% oiWindow(oi);

%% Make a sensor array that can see the whole range

% The sensor size is big enough to capture the whole chart
sensorArray = sensorCreateArray('array type','ovt','exp time',0.1,'size',2*[64 96],'noise flag',0);
sA          = sensorComputeArray(sensorArray,oi,'method','average');

% This is the combined
% sensorWindow(sA);
uData = sensorPlot(sA,'volts hline',[1 48],'twolines',true,'no fig',true);
set(gca,'yscale','log');

assert(abs(sum(uData.pixData{1})/15.8806) - 1 < 1e-3);

%%
sA      = sensorComputeArray(sensorArray,oi,'method','bestsnr');
uData = sensorPlot(sA,'volts hline',[1 48],'twolines',true,'no fig',true);
assert(abs(sum(uData.pixData{1})/15.8778) - 1 < 1e-3);

%% END
end
