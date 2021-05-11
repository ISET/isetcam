%% Simulate a sensor with stacked pixels, as in the Foveon sensor
%
% The method here is also useful for those times we want to estimate sensor
% responses in the absence of demosaicking.
%
% Foveon and Langfelder use this design.
%
% See also: ipCompute
%
% Copyright ImagEval Consultants, LLC, 2012_

%%
ieInit

%% Initialize a simple scene

% A few simple parameters
horizontalFOV = 8;
meanLuminance = 100;
patchSize = 64;
scene = sceneCreate('macbeth d65', patchSize);
scene = sceneAdjustLuminance(scene, meanLuminance);
scene = sceneSet(scene, 'hfov', horizontalFOV);
% ieAddObject(scene); sceneWindow;

%% Build the OI
oi = oiCreate;
oi = oiSet(oi, 'optics fnumber', 4);
oi = oiSet(oi, 'optics focal length', 3e-3); % units are meters
oi = oiCompute(scene, oi);
% ieAddObject(oi); oiWindow;

%% Create a cell array of three monochrome sensors

% Make the sensor an XYZ type.  For Foveon or other simulation, but in
% different color filters.
wave = sceneGet(scene, 'wave');
filterFile = 'Foveon';
fSpectra = ieReadSpectra(filterFile, wave); %load and interpolate filters
fSpectra = ieScale(fSpectra, 1);
filterNames = {'rX', 'gY', 'bZ'};

% Create a monochrome sensor.  We will reuse this structure to compute each
% of the complete color filters.]
clear sensorMonochrome;
for ii = 1:3
    sensorMonochrome(ii) = sensorCreate('monochrome'); %#ok<*SAGROW>
    sensorMonochrome(ii) = sensorSet(sensorMonochrome(ii), 'pixel size constant fill factor', [1.4, 1.4]*1e-6);
    sensorMonochrome(ii) = sensorSet(sensorMonochrome(ii), 'exp time', 0.1);
    sensorMonochrome(ii) = sensorSet(sensorMonochrome(ii), 'filterspectra', fSpectra(:, ii));
    sensorMonochrome(ii) = sensorSet(sensorMonochrome(ii), 'Name', sprintf('Channel-%.0f', ii));
    sensorMonochrome(ii) = sensorSetSizeToFOV(sensorMonochrome(ii), sceneGet(scene, 'fov'), oi);
    sensorMonochrome(ii) = sensorSet(sensorMonochrome(ii), 'wave', wave);
end

%% Loop on the filters and calculate monochrome sensor planes

% sensorCompute can take an array of sensors as input.
sensorMonochrome = sensorCompute(sensorMonochrome, oi);

sz = sensorGet(sensorMonochrome(1), 'size');
nChannels = size(fSpectra, 2);
im = zeros(sz(1), sz(2), nChannels);
for ii = 1:3
    im(:, :, ii) = sensorGet(sensorMonochrome(ii), 'volts');
end

sensorWindow(sensorMonochrome(1));

%% Render the Foveon sensor data with the image processor (ipCompute)

% Match a new sensor to the Foveon sensor properties
sensorFoveon = sensorCreate;
sensorFoveon = sensorSet(sensorFoveon, 'pixel size constant fill factor', [1.4, 1.4]*1e-6);
sensorFoveon = sensorSet(sensorFoveon, 'exp time', 0.1);
sensorFoveon = sensorSetSizeToFOV(sensorFoveon, sceneGet(scene, 'fov'), oi);
sensorFoveon = sensorSet(sensorFoveon, 'wave', wave);

% Place the data (im) into the volts field of the matched sensor. The
% sensor has the same properties as the monochrome sensor, but it has the
% proper color filters.

% Put the Foveon color filters here
sensorFoveon = sensorSet(sensorFoveon, 'filter spectra', fSpectra);
sensorPlot(sensorFoveon, 'color filters');

% Put the Foveon simulation data here
sensorFoveon = sensorSet(sensorFoveon, 'volts', im);

% When the sensor data are complete (nxmx3), ipCompute treats the sensor
% like a triple-well and produces an output without demosaicking.
ip = ipCreate;
ip = ipCompute(ip, sensorFoveon);
ip = ipSet(ip, 'name', 'Foveon Triple Well');
ipWindow(ip);

%% Perform ane equivalent calculation with a conventional RGB Bayer sensor

filterFile = 'NikonD1';
fSpectra = ieReadSpectra(filterFile, wave); %load and interpolate filters
fSpectra = ieScale(fSpectra, 1);

sensorBayer = sensorCreate; % Default Bayer sensor
sensorBayer = sensorSet(sensorBayer, 'filterspectra', fSpectra);
sensorPlot(sensorBayer, 'color filters');

% Match the size and exposure time and field of view
sensorBayer = sensorSet(sensorBayer, 'pixel size constant fill factor', [1.4, 1.4]*1e-6);
sensorBayer = sensorSet(sensorBayer, 'exp time', 0.1);
sensorBayer = sensorSetSizeToFOV(sensorBayer, sceneGet(scene, 'fov'), oi);

% Compute
sensorBayer = sensorCompute(sensorBayer, oi);

% Convert to an image - Try zooming and comparing this one with the Triple
% Well.  Notice the difference in noise and the difference in mosaic
ip = ipCompute(ip, sensorBayer);
ip = ipSet(ip, 'name', 'Bayer Mosaic');
ipWindow(ip);

%%
