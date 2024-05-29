%% Illustrate the imx490
%
%

%%
ieInit;

%% In this case the volts are 4x but the electrons are equal
%
% As it should be, IMHO.

scene = sceneCreate('uniform',256);
oi = oiCreate;
oi = oiCompute(oi,scene);   % oiWindow(oi);
oi = oiCrop(oi,'border');
oi = oiSpatialResample(oi,3e-6);
[sensor,metadata] = imx490Compute(oi,'method','average','exptime',1/10);

sensorWindow(sensor);

%% Show the uniform field responses in case.

% Note:  The ratio of electron capture makes sense.  The conversion gain,
% however, differs so when we plot w.r.t volts the ratios are not as you
% might naively expect.  The dv values follow volts.

% For the HDR car scene use exptime of 0.1 sec
sArray = metadata.sensorArray;
sensorWindow(sArray{1});
sensorWindow(sArray{2});
sensorWindow(sArray{3});
sensorWindow(sArray{4});

%% Various checks.
e1 = sensorGet(sArray{1},'electrons');
e2 = sensorGet(sArray{2},'electrons');
ieNewGraphWin; plot(e1(:),e2(:),'.');
xlabel('E Sensor 1'); ylabel('E Sensor 2');
identityLine; grid on;

v1 = sensorGet(sArray{1},'volts');
v2 = sensorGet(sArray{2},'volts');
ieNewGraphWin; plot(v1(:),v2(:),'.');
xlabel('V Sensor 1'); ylabel('V Sensor 2');
identityLine; grid on;

% e3 is 1/9th the area, so 1/9th the electrons of e1
e3 = sensorGet(sArray{3},'electrons');
ieNewGraphWin; plot(e1(:),e3(:),'.');
xlabel('E Sensor 1'); ylabel('E Sensor 3');
identityLine; grid on;

dv1 = sensorGet(sArray{1},'dv');
dv2 = sensorGet(sArray{2},'dv');
ieNewGraphWin; plot(dv1(:),dv2(:),'.');
xlabel('DV Sensor 1'); ylabel('DV Sensor 2');
identityLine; grid on;


%% Now try with a complex image

load('HDR-02-Brian','scene');

oi = oiCreate;
oi = oiCompute(oi,scene);   % oiWindow(oi);
oi = oiCrop(oi,'border');
oi = oiSpatialResample(oi,3,'um'); % oiWindow(oi);
oi2 = oiCompute(oi,scene,'crop',true,'pixel size',3e-6);   % oiWindow(oi2);
oi2 = oiSpatialResample(oi2,3,'um'); % oiWindow(oi);

[sensor,metadata] = imx490Compute(oi,'method','average',...
    'exptime',1/10, 'noise flag',0);

% sensorWindow(sensor);
%{
  v = sensorGet(sensor,'volts');
  if min(v(:)) < sensorGet(sensor,'analog offset')
    disp('Ooops')
    % It seems we do not always have a voltage > analog offset
  end 
%}
sArray = metadata.sensorArray;

% Note that the electrons match up to voltage saturation
e1 = sensorGet(sArray{1},'electrons');
e2 = sensorGet(sArray{2},'electrons');
ieNewGraphWin; plot(e1(:),e2(:),'.');
xlabel('E Sensor 1'); ylabel('E Sensor 2');
identityLine; grid on;

v1 = sensorGet(sArray{1},'volts');
v2 = sensorGet(sArray{2},'volts');

ieNewGraphWin; 
plot(v1(:),v2(:),'.'); identityLine; grid on;
xlabel('V Sensor 1'); ylabel('V Sensor 2');
identityLine; grid on;

% Change into local/imx490
% {
volts = sensorGet(sensor,'volts');
mesh(volts); set(gca,'zscale','log');

ieNewGraphWin; 
for ii=1:4
    srgb = sensorGet(sArray{ii},'rgb');
    imagesc(srgb); truesize; axis off;
    fname = ...
     fullfile(isetRootPath,'local','imx490',sprintf(imx490-%d.png',ii);
    exportgraphics(gcf,sprintf('imx490-%d.png',ii));   
end
srgb = sensorGet(sensor,'rgb');
imagesc(srgb.^0.3); truesize; axis off
%}

% exportgraphics(gcf,sprintf('imx490-average.png'));   

%{
sensorWindow(sensor);

sensorWindow(sArray{1});
sensorWindow(sArray{2});
sensorWindow(sArray{3});
sensorWindow(sArray{4});
%}

%% Make an ideal form of the image

scene = sceneCreate('uniform',256);
oi = oiCreate;
oi = oiCompute(oi,scene);   % oiWindow(oi);
oi = oiCrop(oi,'border');
oi = oiSpatialResample(oi, 3,'um');
oiGet(oi,'size')

% Calculate the imx490 sensor
sensor = imx490Compute(oi,'method','average','exptime',1/10);

% Could just do an oiGet(oi,'xyz')
%
% Or we can create a matched, ideal X,Y,Z sensors that can calculate
% the XYZ values at each pixel.
sensorI = sensorCreateIdeal('match xyz',sensor);
sensorI = sensorCompute(sensorI,oi);
sensorWindow(sensorI(3));
sensorGet(sensorI(1),'pixel fill factor')

% The sensor data and the oi data have the same vector length.  Apart from
% maybe a pixel at one edge or the other, they should be aligned
%

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

%% END
