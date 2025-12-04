%% s_sensorColorRouter
%
% Experiments with changing the effective color filters using a color
% router design from Peter C. and Shanhui.
%
%

%% Make a test scene

scene = sceneCreate;
sceneWindow(scene);

%% Some kind of optics

oi = oiCreate('wvf');
oi = oiCompute(oi,scene);
oiWindow(oi);

%% Build the two types of sensors

sensor_original = sensorCreate('imx363');

%% Building up the CMOS QE and the IR filter
%
% We have an irFilter for the imx363
%
% Here are plots from the web of CMOS imager QE
%
% If we accept the CMOS QE and the IR Filter, we can derive the sony
% imx363 color filters
%
% We have the Sony spectral QE, so from that and some assumption about
% CMOS QE and the ir filter we can derive the color filters.
%

sensor1 = sensorCreate('imx363');

wave = sensorGet(sensor1,'wave');

cmosQE = ieReadSpectra('sonyCMOSQE',wave);
cmosQE = (1.2*cmosQE);

irFilter = sensorGet(sensor1,'irfilter');
spectralQE = sensorGet(sensor1,'spectral qe');

%
% sQE = irF * cmosQE * cf;
% cf = sQE / (irF * cmosQE)

% New color figures
%
cf = spectralQE ./ (irFilter .* cmosQE);

ieFigure;
plot(wave,cf);

%% Rebuild to check that we multiplied right
%{
sQE_checked = irFilter .* cmosQE .* cf;
ieFigure;
plot(wave,spectralQE); hold on;
plot(wave,sQE_checked); 

ieFigure; plot(sQE_checked(:),spectralQE(:),'.');
identityLine; grid on;
%}

% The ir filter is already there
sensor1 = sensorSet(sensor1,'pixel spectral qe',cmosQE);
sensor1 = sensorSet(sensor1,'filter spectra',cf);

% Should be unchanged, and it is!
sensorPlot(sensor1,'spectral qe');

%% Now we replace the color filters with the routers


%% Read the color filters from the router simulation

router_oe = ieReadSpectra('singleLayerColorRouter',wave);
% load('routerdata','OE','wavelength');
ieFigure;
plot(wave,router_oe); grid on;
xlabel('Wavelength (nm)'); ylabel('Efficiency');

sensor_router = sensor1;
sensor_router = sensorSet(sensor_router,'filter spectra',router_oe);
sensorPlot(sensor_router,'spectral qe');


%% Auto exposure
sensor1 = sensorSet(sensor1,'auto exposure',true);
sensor1 = sensorSet(sensor1,'noiseflag',-2);
sensor1 = sensorCompute(sensor1,oi);
expTime = sensorGet(sensor1,'exp time');
sensorWindow(sensor1);

% Short exposure
sensor1 = sensorSet(sensor1,'exp time',expTime/8);
sensor1 = sensorCompute(sensor1,oi);

sensorWindow(sensor1);

%% Adjust the pixel size of the router sensor

pSize = sensorGet(sensor1,'pixel size')
sensor_router = sensorSet(sensor_router,'pixel size constant fill factor', 2*pSize);
sensorGet(sensor_router,'pixel size')

%% Change the the color filter pattern so we just have 1 color filter

for ii=1:3
    sensor_router_array(ii) = sensorSet(sensor_router,'filter spectra',router_oe(:,ii));
    sensor_router_array(ii).cfa.pattern = 1;
end

sensor_router_array = sensorCompute(sensor_router_array,oi);

%%

% Use the s_sensorStackedPixel script in scripts/sensor as a model for
% how to create the three different sensor_router array.

