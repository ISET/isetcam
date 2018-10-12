% Create code to compile for producing a sensor output data file
%
% c_sensorCompute
%
%

scene = sceneCreate;
oi = oiCreate;
oi = oiCompute(oi,scene);
sensor = sensorCreate;
sensor = sensorCompute(sensor,oi);
rgb = sensorGet(sensor,'rgb');
save('sensor1','rgb');

%%