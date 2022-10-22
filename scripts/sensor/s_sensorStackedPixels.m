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

horizontalFOV = 8;
meanLuminance = 100;
patchSize = 64;

scene = sceneCreate('macbeth d65',patchSize);
scene = sceneAdjustLuminance(scene,meanLuminance);
scene = sceneSet(scene,'hfov',horizontalFOV);
% sceneWindow(scene);

%% Build the OI
oi = oiCreate;
oi = oiSet(oi,'optics fnumber',4);
oi = oiSet(oi,'optics focal length',3e-3);   % units are meters
oi = oiCompute(scene,oi);
% oiWindow(oi);

%% Create a cell array of three monochrome sensors

% Make the sensor an XYZ type.  For Foveon or other simulation, but in
% different color filters.
wave   = sceneGet(scene,'wave');
filterFile = 'Foveon';
fSpectra = ieReadSpectra(filterFile,wave);   %load and interpolate filters
fSpectra = ieScale(fSpectra,1);
filterNames = {'rX','gY','bZ'};

% Create a monochrome sensor.  We will reuse this structure to compute each
% of the complete color filters.]
clear sensorMonochrome;
for ii=1:3
    sensorMonochrome(ii) = sensorCreate('monochrome'); %#ok<*SAGROW>
    sensorMonochrome(ii) = sensorSet(sensorMonochrome(ii),'pixel size constant fill factor',[1.4 1.4]*1e-6);
    sensorMonochrome(ii) = sensorSet(sensorMonochrome(ii),'exp time',0.1);
    sensorMonochrome(ii) = sensorSet(sensorMonochrome(ii),'filterspectra',fSpectra(:,ii));
    sensorMonochrome(ii) = sensorSet(sensorMonochrome(ii),'Name',sprintf('Channel-%.0f',ii));
    sensorMonochrome(ii) = sensorSetSizeToFOV(sensorMonochrome(ii),sceneGet(scene,'fov'),oi);
    sensorMonochrome(ii) = sensorSet(sensorMonochrome(ii),'wave',wave);
end

%% Calculate several monochrome sensor planes, each with a different color filter

% sensorCompute can take an array of sensors as input.
sensorMonochrome = sensorCompute(sensorMonochrome,oi);

%% Pull out the data from each of the complete monochrome data.
sz = sensorGet(sensorMonochrome(1),'size');
nChannels = size(fSpectra,2);
im = zeros(sz(1),sz(2),nChannels);
for ii=1:3
    im(:,:,ii) = sensorGet(sensorMonochrome(ii),'volts');
end

% sensorWindow(sensorMonochrome(1));

%% Render the Foveon sensor data with the image processor (ipCompute)

% Match a new sensor to the Foveon sensor properties
sensorFoveon = sensorCreate;
sensorFoveon = sensorSet(sensorFoveon,'name','foveon');
sensorFoveon = sensorSet(sensorFoveon,'pixel size constant fill factor',[1.4 1.4]*1e-6);
sensorFoveon = sensorSet(sensorFoveon,'autoexp',1);
sensorFoveon = sensorSetSizeToFOV(sensorFoveon,sceneGet(scene,'fov'),oi);
sensorFoveon = sensorSet(sensorFoveon,'wave',wave);

% Place the data (im) into the volts field of the matched sensor. The
% sensor has the same properties as the monochrome sensor, but it has the
% proper color filters.

% Put the Foveon color filters here
sensorFoveon = sensorSet(sensorFoveon,'filter spectra',fSpectra);
sensorFoveon = sensorSet(sensorFoveon,'pattern',[2]);

sensorPlot(sensorFoveon,'color filters');

% Put the Foveon simulation data here
sensorFoveon = sensorSet(sensorFoveon,'volts',im);
sensorWindow(sensorFoveon);

%% When the sensor data are complete (nxmx3), 
% ipCompute treats the sensor like a triple-well and produces an output
% without demosaicking.
ip = ipCreate;
ip = ipCompute(ip,sensorFoveon);
ip = ipSet(ip,'name','Foveon Triple Well');
ipWindow(ip);
uDataF = ipPlot(ip,'horizontal line',[1 120]);

%% Perform ane equivalent calculation with a conventional RGB Bayer sensor

filterFile = 'NikonD1';
fSpectra = ieReadSpectra(filterFile,wave);   %load and interpolate filters
fSpectra = ieScale(fSpectra,1); 

sensorBayer = sensorCreate;   % Default Bayer sensor
sensorBayer = sensorSet(sensorBayer,'filterspectra',fSpectra);
sensorPlot(sensorBayer,'color filters');

% Match the size and exposure time and field of view
sensorBayer = sensorSet(sensorBayer,'pixel size constant fill factor',[1.4 1.4]*1e-6);
sensorBayer = sensorSet(sensorBayer,'autoexp',1);
sensorBayer = sensorSetSizeToFOV(sensorBayer,sceneGet(scene,'fov'),oi);

% Compute
sensorBayer = sensorCompute(sensorBayer,oi);
sensorWindow(sensorBayer);

%% Convert to an image and plot

% Try zooming and comparing this one with the Triple
% Well.  Notice the difference in noise and the difference in mosaic
ip = ipCompute(ip,sensorBayer);
ip = ipSet(ip,'name','Bayer Mosaic');
ipWindow(ip);

uDataB = ipPlot(ip,'horizontal line',[1 120]);

%% To Notice
% The noise on the high sampling rate is Poisson noise.  The smooth curve
% on the lower resolution Nikon sensor is because the data are linearly
% interpolated.
%
% Here they are plotted on the same graph for the red channel.  There is
% almost no difference in sharpness, probably because of the lens
% pointspread.  The additional noise is probably not very detrimental, but
% it is there.

ieNewGraphWin;
plot(uDataB.pos,uDataB.values(:,1),'r--');
hold on;
plot(uDataF.pos,uDataF.values(:,1),'k-');
xlabel('Position'); ylabel('DV'); grid on;

legend({'Bayer','Foveon'});


%% end
