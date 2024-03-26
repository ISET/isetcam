%% Illustrate the imx490
%
%

%% In this case the volts are 4x but the electrons are equal
%
% As it should be, IMHO.

scene = sceneCreate('uniform',256);
oi = oiCreate;
oi = oiCompute(oi,scene);   % oiWindow(oi);
oi = oiCrop(oi,'border');
[sensor,metadata] = imx490Compute(oi,'method','average','exptime',1/10);

% For the HDR car scene use exptime of 0.1 sec
sArray = metadata.sensorArray;

sensorWindow(sensor);

% Note:  The ratio of electron capture makes sense.  The conversion gain,
% however, differs so when we plot w.r.t volts the ratios are not as you
% might naively expect.  The dv values follow volts.
sensorWindow(sArray{1});
sensorWindow(sArray{2});
sensorWindow(sArray{3});
sensorWindow(sArray{4});

%% Various checks.
e1 = sensorGet(sArray{1},'electrons');
e2 = sensorGet(sArray{2},'electrons');
ieNewGraphWin; plot(e1(:),e2(:),'.');
identityLine; grid on;

v1 = sensorGet(sArray{1},'volts');
v2 = sensorGet(sArray{2},'volts');
ieNewGraphWin; plot(v1(:),v2(:),'.');
identityLine; grid on;

% e3 is 1/9th the area, so 1/9th the electrons of e1
e3 = sensorGet(sArray{3},'electrons');
ieNewGraphWin; plot(e1(:),e3(:),'.');
identityLine; grid on;

dv1 = sensorGet(sArray{1},'dv');
dv2 = sensorGet(sArray{2},'dv');
ieNewGraphWin; plot(dv1(:),dv2(:),'.');
identityLine; grid on;


%% Now try with a complex image

load('HDR-02-Brian','scene');
oi = oiCreate;
oi = oiCompute(oi,scene);   % oiWindow(oi);
oi = oiCrop(oi,'border');
[sensor,metadata] = imx490Compute(oi,'method','average','exptime',1/10);
sArray = metadata.sensorArray;

% Note that the electrons match up to voltage saturation
e1 = sensorGet(sArray{1},'electrons');
e2 = sensorGet(sArray{2},'electrons');
ieNewGraphWin; plot(e1(:),e2(:),'.');
identityLine; grid on;

v1 = sensorGet(sArray{1},'volts');
v2 = sensorGet(sArray{2},'volts');
ieNewGraphWin; plot(v1(:),v2(:),'.');
identityLine; grid on;

sensorWindow(sArray{1});
sensorWindow(sArray{2});

%%
[sensor,metadata] = imx490Compute(oi,'method','best snr','exptime',1/3);

%%
ip = ipCreate;
ip = ipCompute(ip,sensor);
ipWindow(ip);

%% For the uniform case, these should be about 4x
uData1 = sensorPlot(sArray{1},'electrons hline',[55 1]);
sensorPlot(sArray{2},'electrons hline',[55 1]);

% These are OK.  A factor of 4.
uData2 = sensorPlot(sArray{3},'electrons hline',[150 1]);
sensorPlot(sArray{4},'electrons hline',[150 1]);

%{
%% Checking that I can match ZL
sensor490 = sensorCreate('imx490-large');
sensor490.pixel

% sensorZL = sensorIMX363V2('row col',[600 800]);
% sensorZL.pixel

pixelSize = 1.8615;
colorFilterFile = '/Users/wandell/Documents/MATLAB/isetcam/data/sensor/colorfilters/auto/ar0132atRGB.mat';
oiSize = [1536        1536];
lpixel_hgain = sensorIMX363V2(...
    'pixelsize', 3*pixelSize*1e-6, ...
    'quantization', '12 bit',...
    'qefilename',colorFilterFile, ...
    'wellcapacity',120000,'fillfactor',1,'isospeed',55, ...
    'rowcol',ceil([oiSize(1) oiSize(2)]/3));

isequal(lpixel_hgain.pixel,sensor490.pixel)
% [common, d1, d2] = comp_struct(lpixel_hgain.pixel,sensor490.pixel)

%%
sensor490 = sensorCreate('imx490-small');
sensor490.pixel
spixel_hgain = sensorIMX363V2('pixelsize', pixelSize*1e-6, ...
    'quantization', '12 bit',...
    'qefilename',colorFilterFile, ...
    'wellcapacity',60000,'fillfactor',1,'isospeed',55, ...
    'rowcol',[oiSize(1) oiSize(2)]);
isequal(spixel_hgain.pixel,sensor490.pixel)
[common, d1, d2] = comp_struct(spixel_hgain.pixel,sensor490.pixel)
%}

