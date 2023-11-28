%% Experiments with ssim
%
% Includes comparisons with S-CIELAB
%
% Used for Psych 221 teaching.


%%
ieInit;

%% Reference scene all the way to a rendered image

% The initial calculation has zero noise
scene = sceneCreate('sweep frequency',512,20);
% scene = sceneCreate;
% sceneWindow(scene);

oi = oiCreate;
oi = oiCompute(oi,scene);
oi = oiCrop(oi,'border');

%% Start with the Sony IMX sesnsor
sensor = sensorCreate('imx363');

% Because we turn off all the noise, we need to set the black level to
% zero.  We should probably do this inside of the sensor set for this
% special case.  
sensor = sensorSet(sensor,'noise flag',-1);
sensor = sensorSet(sensor,'zero level',0);

% Adjust the sensor array size and use a long exposure for relatively
% little photon noise.
sensor = sensorSet(sensor,'fov',oiGet(oi,'fov'),oi);
sensor = sensorSet(sensor,'autoexposure',true);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

%%
ip = ipCreate;
ip = ipSet(ip,'name','default');
ip = ipSet(ip,'internal cs','XYZ');
ip = ipSet(ip,'conversion method sensor','MCC Optimized');
ip = ipSet(ip,'name','MCC-XYZ');
ip = ipSet(ip,'correction method illuminant','white world');
ip = ipCompute(ip,sensor);
ipWindow(ip);

% Here is the reference luminance
refsRGB = ipGet(ip,'srgb');
refLum = sum(refsRGB,3)/3;

%% Allow noise and shorten the exposure duration to create a noisy version
sensor = sensorSet(sensor,'noise flag',2);

% We turn on the noise, so we put back the black level.
sensor = sensorSet(sensor,'zero level',64);
sensor = sensorSet(sensor,'exp time',0.005);

sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

% Compute from sensor to sRGB
ip = ipCompute(ip,sensor);
ipWindow(ip);

testsRGB = ipGet(ip,'srgb');
testLum = sum(test,3)/3;

%%

ieNewGraphWin;
montage({refLum,testLum});

ieNewGraphWin;
montage({refsRGB,testsRGB});

%% Read for metrics

[val,ssimmap] = ssim(testLum,refLum);

% SSIM 1 is highest quality.  We want this to be an error map, so we
% subtract from one.
ieNewGraphWin;
imagesc(1 - mean(ssimmap,3)); axis image;
title('SSIM Error')
colorbar; axis image; axis off

%%

ieNewGraphWin;
mesh(1 - mean(ssimmap,3));

%% Now try S-CIELAB

params = scParams;
fov = 10;
params.sampPerDeg = round(size(test,1)/fov);
testXYZ = ieClip(srgb2xyz(test),0,[]);
refXYZ  = ieClip(srgb2xyz(refsRGB),0,[]);

dEimg = scielab(testXYZ,refXYZ,[.92 .98 .98],params);
ieNewGraphWin; imagesc(dEimg);
colorbar; axis image; axis off

ieNewGraphWin;
mesh(dEimg);

%%