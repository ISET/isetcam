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
oi = oiCompute(oi,scene,'crop',true);
% oiWindow(oi);

%% Start with the Sony IMX sesnsor
sensor = sensorCreate('imx363');

% Because we turn off all the noise, we need to set the black level to
% zero.  We should probably do this inside of the sensor set for this
% special case.  
sensor = sensorSet(sensor,'noise flag',-1);
sensor = sensorSet(sensor,'zero level',64);

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
ip = ipSet(ip,'correction method illuminant','gray world');
ip = ipCompute(ip,sensor);
ipWindow(ip);

% Here is the reference luminance
refsRGB = ipGet(ip,'srgb');

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

fprintf('Test sRGB mean %0.1f\nRef  sRGB mean %.1f\n',mean(testsRGB(:)), mean(refsRGB(:)));

%% To fix

% testsRGB and refsRGB do not have the same mean.
% I think they should, but what I did above was let the exposure
% duration vary between the two captures.  Maybe don't do that.

%% Compare the images visually, with color

ieNewGraphWin;
montage({refsRGB,testsRGB});

%% This is the comparison SSIM sees

ieNewGraphWin;
montage({sum(refsRGB,3)/3,sum(testsRGB,3)/3});

%% Read for metrics

[val,ssimmap] = ssim(testsRGB,refsRGB);

% SSIM 1 is highest quality.  We want this to be an error map, so we
% subtract from one.
ieNewGraphWin;
imagesc(1 - mean(ssimmap,3)); axis image;
title('SSIM Error (1-ssim)')
colorbar; axis image; axis off

%%
%{
ieNewGraphWin;
mesh(1 - mean(ssimmap,3));
%}

%% Now try S-CIELAB

params = scParams;
ieFigure; 
tiledlayout(2,2);

fov = 1;
params.sampPerDeg = round(size(testsRGB,1)/fov);
testXYZ = ieClip(srgb2xyz(testsRGB),0,[]);
refXYZ  = ieClip(srgb2xyz(refsRGB),0,[]);

nexttile;
imagesc(refsRGB);
title('Reference image')

nexttile;
imagesc(testsRGB);
title('Noisy image')

whitePt = [.92 .98 .98];
clims = [0 20];
dEimg = scielab(testXYZ,refXYZ,whitePt,params);

nexttile;
imagesc(dEimg,clims);
colorbar; axis image; axis off
title(sprintf('FOV: %.1f',fov));


params = scParams;
fov = 20;
params.sampPerDeg = round(size(testsRGB,1)/fov);
testXYZ = ieClip(srgb2xyz(testsRGB),0,[]);
refXYZ  = ieClip(srgb2xyz(refsRGB),0,[]);

dEimg = scielab(testXYZ,refXYZ,whitePt,params);
nexttile;
imagesc(dEimg,clims);
colorbar; axis image; axis off
title(sprintf('FOV: %.1f',fov));


% ieNewGraphWin;
% mesh(dEimg);

%%