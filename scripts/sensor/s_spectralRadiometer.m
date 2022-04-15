%% Build a sensor that simulates a spectral radiance meter
%
%  We will use the data from this sensor to estimate the Photon noise
%  for different spectral lights
%
% See also
%   s_radiometerCreate;

%% 
ieInit;

%% Make the OI
%
% We can create different scene spectral radiances easily.
% Maybe we should have
%
%   sceneCreate('uniform',specifyRelativeRadiance);
%

scene = sceneCreate('uniformD65');  % sceneWindow(scene);
oi = oiCreate;
oi = oiCompute(oi,scene);

%% Create a radiometer sensor
wave = 400:700;

[data, filterNames, fileData]  = ieReadColorFilter(wave,'radiometer');
nFilters = size(data,2);
filterOrder = 1:nFilters;
filterFile = fullfile(isetRootPath, 'data', 'sensor', 'colorfilters', 'radiometer.mat');
wSamples = zeros(size(filterNames));
for ii=1:numel(filterNames)
    wSamples(ii) = str2double(filterNames{ii});
end

%% Make the sensor
pixel = pixelCreate('default', wave);
pixel = pixelSet(pixel,'fill factor',1);
pixel = pixelSet(pixel,'size same fill factor',[1.5 1.5]*1e-6);

sensorRadiometer = sensorCreate('custom', pixel, filterOrder, filterFile,[], wave);
sensorRadiometer = sensorSet(sensorRadiometer,'size',[10 nFilters]);

%% The choice of exposure time matters a lot
sensorRadiometer = sensorSet(sensorRadiometer,'exposure time',1/100);

sensorRadiometer = sensorSet(sensorRadiometer,'noise flag',-2);
sensorRadiometer = sensorCompute(sensorRadiometer,oi);
electrons = sensorGet(sensorRadiometer,'electrons');
sensorWindow(sensorRadiometer);

sensorRadiometer = sensorSet(sensorRadiometer,'noise flag',-1);
sensorRadiometer = sensorCompute(sensorRadiometer,oi);
electronsNoNoise = sensorGet(sensorRadiometer,'electrons');

%% Get the electrons across a line

thisLine = electrons(5,:);
sd = thisLine .^ 0.5;
thisLineNoNoise = electronsNoNoise(5,:);

ieNewGraphWin;
errorbar(wSamples,thisLine,2*sd);
hold on;
plot(wSamples,thisLineNoNoise,'k-');

grid on; xlabel('Wavelength (nm)'); ylabel('Electrons');
set(gca,'ylim',[0 round(1.2*max(thisLine(:)),-1)]);

%%