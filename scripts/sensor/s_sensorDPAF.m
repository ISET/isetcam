%% Create a sensor with a rectangular pixel
%
%  This might be for simulating dual pixel auto focus
%
%  We can put a single microlens on top of the two pixels
%

%% Initialize a scene and oi
ieInit;

s_initSO;

%% Make a sensor that has rectangular pixels

sensor = sensorCreate;

pixel = sensorGet(sensor,'pixel');
pixel = pixelSet(pixel,'height',1.4e-6);
sensor = sensorSet(sensor,'pixel',pixel);

sz = sensorGet(sensor,'size');
sensor = sensorSet(sensor,'size',[sz(1)*4, sz(2)*2]);

% Set the CFA pattern accounting for the dual pixel architecture
sensor = sensorSet(sensor,'pattern',[2 1 ; 2 1; 3 2; 3 2]);


%% Compute the sensor data

% Notice that we get the spatial structure of the image right, even though
% the pixels are rectangular.
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

%% Now the other way around

sensor = sensorCreate;

pixel = sensorGet(sensor,'pixel');
pixel = pixelSet(pixel,'width',1.4e-6);
sensor = sensorSet(sensor,'pixel',pixel);

sz = sensorGet(sensor,'size');
sensor = sensorSet(sensor,'size',[sz(1)*2, sz(2)*4]);

% Set the CFA pattern accounting for the dual pixel architecture
sensor = sensorSet(sensor,'pattern',[2 2 1 1 ; 3 3 2 2]);

sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

%% END

