%% Illustrate the imx490
%
% A split pixel sensor design.
% 
% ISET implements a special compute method that begins with the main sensor
% style (imx363) but then creates the large and small pixel sizes.  It also
% creates the low and high gain (4x).  So 4 total outputs.
%
% The individual arrays are returned as metadata.  The combined response,
% computed either as an average or as best snr, are returned in the main
% sensor.
%
% This script illustrates a simple computational case (uniform field) and
% an HDR image.  We compare the electrons and volts separately to check the
% calculations.  The electrons are the same, but the volts differ because
% of the analog gain difference.
%
% See also
%   imx490Compute
%   s_hsIMX490 (isethdrsensor)

%%
ieInit;

%% In this case the volts are 4x but the electrons are equal
%
% As it should be, IMHO.

scene = sceneCreate('uniform',256);

oi = oiCreate;

% Crops the edge and makes the spatial sample 3 microns
oi = oiCompute(oi,scene,'crop',true,'pixel size',3e-6);
% oiWindow(oi);

[sensor,metadata] = imx490Compute(oi,'method','average','exptime',1/10);
sArray = metadata.sensorArray;

%% Have a look.  This is a boring case in which everything is uniforms
%{
% The individual sensor arrays are here

% This is the combined response.
sensorWindow(sensor);

sensorWindow(sArray{1});
sensorWindow(sArray{2});
sensorWindow(sArray{3});
sensorWindow(sArray{4});
%}

%% Confirm the values.

% The same number of electrons when they are both large.  

% Same number of electrons in big and small
e1 = sensorGet(sArray{1},'electrons');
e2 = sensorGet(sArray{2},'electrons');
ieNewGraphWin; plot(e1(:),e2(:),'.');
identityLine; grid on;
xlabel('E Low gain, large'); ylabel('E High gain, large');

% Differ in voltages because of the analog gain (4x)
v1 = sensorGet(sArray{1},'volts');
v2 = sensorGet(sArray{2},'volts');
ieNewGraphWin; plot(v1(:),v2(:),'.');
xlabel('V Low gain, large'); ylabel('V High gain, large');
identityLine; grid on;

% The DV follows the volts
dv1 = sensorGet(sArray{1},'dv');
dv2 = sensorGet(sArray{2},'dv');
ieNewGraphWin; plot(dv1(:),dv2(:),'.');
xlabel('DV Low gain, large'); ylabel('DV High gain, large');
identityLine; grid on;

% Large and small pixels differ in electrons because  e3 is 1/9th the area,
% so 1/9th the electrons of e1.  The well capacity allows e3 to keep going.
e3 = sensorGet(sArray{3},'electrons');
ieNewGraphWin; plot(e1(:),e3(:),'.');
xlabel('E Low gain, large'); ylabel('E Low gain, small');
identityLine; grid on;

%% Now compute with a complex image

load('HDR-02-Brian','scene');
oi = oiCreate;
oi = oiCompute(oi,scene,'crop',true,'pixel size',3e-6);   % oiWindow(oi);

[sensor,metadata] = imx490Compute(oi,'method','average','exptime',1/10);
sArray = metadata.sensorArray;

%% Similar checks

% The electrons match up to voltage saturation
e1 = sensorGet(sArray{1},'electrons');
e2 = sensorGet(sArray{2},'electrons');
ieNewGraphWin; plot(e1(:),e2(:),'.');
identityLine; grid on;
xlabel('E Low gain, large'); ylabel('E High gain, large');

% The voltages are scaled
v1 = sensorGet(sArray{1},'volts');
v2 = sensorGet(sArray{2},'volts');
ieNewGraphWin; plot(v1(:),v2(:),'.');
identityLine; grid on;
xlabel('V Low gain, large'); ylabel('V High gain, large');

%%  You can see the individual arrays and the combined array

sensorWindow(sArray{1});
sensorWindow(sArray{2});
sensorWindow(sArray{3});
sensorWindow(sArray{4});
sensorWindow(sensor);
sensorSet(sensor,'gamma',0.3);

%% Compute using the bestr snr reconstruction method

[sensor,metadata] = imx490Compute(oi,'method','best snr','exptime',1/3);
sArray = metadata.sensorArray;

%%
sensorWindow(sArray{1});
sensorWindow(sArray{2});
sensorWindow(sArray{3});
sensorWindow(sArray{4});
sensorWindow(sensor);
sensorSet(sensor,'gamma',0.3);

%% The color management for this sensor is off.
% BW should fix.

ip = ipCreate;
ip = ipCompute(ip,sensor);
ipWindow(ip);

%% These should match
uData1 = sensorPlot(sArray{1},'electrons hline',[55 1],'no fig',true);
sensorPlot(sArray{2},'electrons hline',[55 1]);
subplot(2,1,1); hold on; 
plot(uData1.pos{1}(:),uData1.data{1}(:),'ko');
subplot(2,1,2); hold on; 
plot(uData1.pos{2}(:),uData1.data{2}(:),'ko');
title('Electrons');

%% These have different analog gain.  A factor of 4.  So shifted on the
% y-axis.
uData1 = sensorPlot(sArray{3},'volts hline',[150 1],'no fig',true);
sensorPlot(sArray{4},'volts hline',[150 1]);
subplot(2,1,1); set(gca,'yscale','log'); hold on; 
semilogy(uData1.pos{1}(:),uData1.data{1}(:),'ko');
subplot(2,1,2); set(gca,'yscale','log');hold on; 
semilogy(uData1.pos{2}(:),uData1.data{2}(:),'ko');
title('Volts');

%% END
