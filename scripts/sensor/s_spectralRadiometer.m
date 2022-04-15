%% Build a sensor that is like a spectral radiance meter
%
%  We will use the data from this sensor to estimate the Photon noise
%  for different spectral lights
%
%

%% Create a radiometer sensor

% This will go into sensorCreate some day.

wave = 400:700;
cfType = 'gaussian';
cPos = 400:1:700; width = 5*ones(size(cPos));

d.data = sensorColorFilter(cfType,wave, cPos, width);
d.wavelength = wave;
filterNames = cell(1,numel(cPos));
for ii=1:numel(cPos), filterNames{ii} = sprintf('%d',ii); end

d.filterNames = filterNames;
d.comment = 'Gaussian filters for spectral radiance meter model';

savedFile = ieSaveColorFilter(d,fullfile(isetRootPath,'data','sensor','colorfilters','radiometer.mat'));

%%
filterOrder = [1:301];
filterFile = fullfile(isetRootPath, 'data', 'sensor', 'colorfilters', 'radiometer.mat');
pixel = pixelCreate('default', wave);
pixel = pixelSet(pixel,'fill factor',1);
pixel = pixelSet(pixel,'size same fill factor',[1.5 1.5]*1e-6);

sensorRadiometer = sensorCreate('custom', pixel, filterOrder, filterFile,[], wave);
sensorRadiometer = sensorSet(sensorRadiometer,'size',[10 301]);

%%
scene = sceneCreate('uniformD65');  sceneWindow(scene);
oi = oiCreate;
oi = oiCompute(oi,scene);
sensorRadiometer = sensorCompute(sensorRadiometer,oi);
sensorWindow(sensorRadiometer);

%% Get the electrons across a line

electrons = sensorGet(sensorRadiometer,'electrons');
ieNewGraphWin;
plot(wave,electrons(5,:));

