function tests = test_opticsMicrolens()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% v_microlens - validate microlens calls
%
% Test the main microlens related routines.
%
% Copyright Imageval Consulting, LLC 2015


%% Each section starts with a fresh copy of the sensor/oi/mlens
ieInit

%%
oi = oiCreate; ieAddObject(oi);
sensor = sensorCreate;
sensor = sensorSet(sensor,'fov',30,oi);
ieAddObject(sensor);

%% Try gets and sets

mlens = mlensCreate;

mlensGet(mlens,'name');
mlensGet(mlens,'type');

assert(mlensGet(mlens,'source fnumber')==4);

mlensGet(mlens,'source diameter','meters');
assert(abs(mlensGet(mlens,'source diameter','microns')- 965.6888) < 1e-4);

assert(abs(mlensGet(mlens,'ml fnumber')-2.5) < 1e-4);
mlensGet(mlens,'ml diameter','meters');
assert(abs(mlensGet(mlens,'ml diameter','microns')-2.8) < 1e-4);

mlensGet(mlens,'source fnumber');
mlensGet(mlens,'chief ray angle');

mlens = mlensSet(mlens,'chief ray angle',10);
mlensGet(mlens,'chief ray angle');

%% Radiance estimates

mlens = mlensCreate;

% Computes the irradiance and various other quantities, storing them in the
% mlens structure itself.
[mlens, psImages] = mlRadiance(mlens);

% Show the distribution as an image
mlIrradianceImage(mlens)

plotML(mlens,'mesh pixel irradiance')

sIrradiance = mlensGet(mlens,'source irradiance');
x = mlensGet(mlens,'x coordinate');
ieNewGraphWin; mesh(x,x,sIrradiance);
h = hot(255); colormap(h(50:250,:)); colorbar;
xlabel('Position (um)');
drawnow;

%%  Phase space images

x = mlensGet(mlens,'x coordinate');
p = mlensGet(mlens,'p coordinate');

ieNewGraphWin([],'tall');
subplot(4,1,1), imagesc(x,p,psImages.source); axis image;
subplot(4,1,2), imagesc(x,p,psImages.lens); axis image;
subplot(4,1,3), imagesc(x,p,psImages.lensOffset); axis image;
subplot(4,1,4), imagesc(x,p,psImages.detector); axis image;
xlabel('x coordinate'); ylabel('p coordinate')
drawnow;

%% Etendue

sensor = ieGetObject('sensor');
sensor = mlAnalyzeArrayEtendue(sensor,'no microlens');
plotSensorEtendue(sensor);
title('No microlens')
drawnow;

sensor = mlAnalyzeArrayEtendue(sensor,'centered');
plotSensorEtendue(sensor);
title('Microlens centered on each pixel')
drawnow;

sensor = mlAnalyzeArrayEtendue(sensor,'optimal');
plotSensorEtendue(sensor);
title('Microlens optimal on each pixel')
drawnow;

%% END
end
