function tests = test_ipColor()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%%  Check that the image sensor transform gets something close
%
% It does in this case, but I have to say I don't like the fits much.
% I do wonder if we should be using a slightly more general function,
% beyond the linear (or even affine) mapping.
%
% See also
%  s_autoLightGroups (isetauto)

%%  Try with an RGBW sensor

s = sensorCreate('rgbw');
sensorQE = sensorGet(s,'spectral qe');
wave = sensorGet(s,'wave');
targetQE = ieReadSpectra('xyzQuanta',wave);

T = imageSensorTransform(sensorQE,targetQE,'',wave, 'mcc');
pred = sensorQE*T;
ieNewGraphWin; plot(wave,pred,'--',wave,targetQE,'k-');

%% Compare to the straight pseudoinverse calculation, without the illuminant

% targetQE = sensorQE*A, so 
A = pinv(sensorQE)*targetQE;
pred = sensorQE*A;
ieNewGraphWin; plot(wave,pred,'--',wave,targetQE,'k-');

%% Use the transform and compare XYZ with the scene XYZ

scene    = sceneCreate;
scene    = sceneSet(scene,'fov',5);
sceneXYZ = sceneGet(scene,'xyz');

oi = oiCreate('wvf');
oi = oiCompute(oi,scene,'crop',true,'pixel size',1.2e-6); 
% oiWindow(oi);

%%
sensor = sensorCreate('rgbw');

% { 
% With these filters we get positions with a ZERO for the red
% channel.  That shouldn't happen.  This is a small image.
% With the normaly rgbw we get a green edge, so the problem is already
% there.

[cf,filterNames] = ieReadColorFilter(sensorGet(sensor,'wave'),'gaussianlBGRWwithIR');
sensor = sensorSet(sensor,'filter transmissivities',cf);
sensor = sensorSet(sensor,'filter names',filterNames);
sensorPlot(sensor,'spectral qe');
%}
% sensor = sensorCreate('MT9V024');
% sensor = sensorCreate('imx363');
% sensor = sensorCreate('nikond100');

sensor = sensorSet(sensor,'match oi',oi);
sensor = sensorSet(sensor,'noise flag',0);
sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor);

ip = ipCreate;
ip = ipCompute(ip,sensor);
% ipWindow(ip);

%%
T  = ieColorTransform(sensor,'XYZ','D65','mcc');
sensorData = ipGet(ip,'sensor data');
sensorXYZ = imageLinearTransform(sensorData,T);

sceneXYZs  = ieScale(sceneXYZ,1);
sensorXYZs = ieScale(sensorXYZ,1);

iePlot(sceneXYZs(:),sensorXYZs(:),'.');
identityLine;

%% sceneXYZ = sensorXYZ*T

sensorXYZs = RGB2XWFormat(sensorXYZs);
[sceneXYZs,row,col] = RGB2XWFormat(sceneXYZs);

T = sensorXYZs\sceneXYZs;

tmp = sensorXYZs*T;
iePlot(sceneXYZs(:),tmp(:),'.');
identityLine;

%% What about an affine fit?

O = ones(size(sensorXYZs,1),1);
sensorXYZ_extended = [sensorXYZs,O];

T = sensorXYZ_extended\sceneXYZs;
tmp = sensorXYZ_extended*T;
iePlot(sceneXYZs(:),tmp(:),'.');
identityLine;

%% END



end
