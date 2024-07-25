%% Illustrate DSNU and PRNU caclulations
%

scene = sceneCreate('uniform',512);
scene = sceneSet(scene,'fov',8);
oi = oiCreate('wvf'); oi = oiCompute(oi,scene);
sensor = sensorCreate;
sensor = sensorSet(sensor,'match oi',oi);

tbl = sensorDescription(sensor,'close window',false,'show',false);

% No photon, electrical or FPN
sensor = sensorSet(sensor,'noise flag',0);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

sensor = sensorSet(sensor,'noise flag',1);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

sensor = sensorSet(sensor,'noise flag',2);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);


sensor = sensorSet(sensor,'dsnu sigma',0.00);
