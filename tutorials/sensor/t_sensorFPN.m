%% Illustrate control of the noise in the sensorCompute caclulation
%

%% 
ieInit;

%% Make a uniform scene
scene = sceneCreate('uniform',512);
scene = sceneSet(scene,'fov',8);
oi = oiCreate('wvf'); oi = oiCompute(oi,scene);
sensor = sensorCreate;
sensor = sensorSet(sensor,'match oi',oi);

%% Set big noise levels for visibility
sensor = sensorSet(sensor,'dsnu sigma',0.05);
sensor = sensorSet(sensor,'prnu sigma',1);
sensor = sensorSet(sensor,'read noise volts',0.1);

%% Show the sensor parameters
[~,~,hdl] = sensorDescription(sensor,'close window',false,'show',false);
set(hdl,"Position",[1   759   627   607]);

%% No photon, electrical or FPN
sensor = sensorSet(sensor,'noise flag',0);
sensor = sensorCompute(sensor,oi);
sensorPlot(sensor,'volts hline',[1 320],'two lines', true);

%% Photon noise only
sensor = sensorSet(sensor,'noise flag',-2);
sensor = sensorCompute(sensor,oi);
sensorPlot(sensor,'volts hline',[1 320],'two lines', true);

%% Photon noise and FPN
sensor = sensorSet(sensor,'noise flag',1);
sensor = sensorCompute(sensor,oi);
sensorPlot(sensor,'volts hline',[1 320],'two lines', true);

%% Photon noise, FPN and electrical
sensor = sensorSet(sensor,'noise flag',2);
sensor = sensorCompute(sensor,oi);
sensorPlot(sensor,'volts hline',[1 320],'two lines', true);

%% END
