%% Illustrate the imx490
%
%

scene = sceneCreate('checkerboard',32);

oi = oiCreate;
oi = oiCompute(oi,scene);
[sensor,sArray] = imx490Compute(oi);

sensorWindow(sensor);

sensorWindow(sArray{1});
sensorWindow(sArray{2});
sensorWindow(sArray{3});
sensorWindow(sArray{4});

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

