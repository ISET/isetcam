%% s_HumanSensor
%
% Create a sensor that models the spatial absorptions of the human cone
% mosaic.  The cone mosaic comprises randomly positioned L,M,S cones at
% some density (typically 4:2:1) and also some blank positions (K).
%
% The parameters for the cone optical and noise properties can be set as
% part of the sensor structure.
%
% Copyright ImagEval Consultants, LLC, 2010.

%% Initialize ISET
ieInit
% If you want to make the same sensor every time, you could set the random
% number generator
% try
%     rng('default');  % To achieve the same result each time
% catch err
%     randn('seed');
% end

%% Create a test scene and optical image
% We illustrate a sweep frequency scene that spans 1 deg field of view.
% We pass that scene through default human optics.

scene = sceneCreate('sweep');
hFov = 1;   % Horizontal field of view (deg)
scene = sceneSet(scene,'fov',hFov);
% vcAddAndSelectObject(scene); sceneWindow;

oi = oiCreate('human');
oi = oiCompute(scene,oi);
% vcAddAndSelectObject(oi); oiWindow(oi);

%% Create the human sensor with a size matched to the scene
% The code here illustrates the complete set of parameters to create a
% sensor mosaic that simulates the cone absorptions.
% The cone aperture is roughly the size in the fovea, though perhaps a
% bit small.  The spacing between cones is a little big.
% These are among the unknown parameters across the retinal surface.

coneSpacing = 1.5;                                % um;
coneAperture = [coneSpacing coneSpacing]*1e-6;    % meters

% This is a pretty good number to summarize human optics with a 60 diopter
% (17 mm) focal length.
micronPerDegree = 300;
degPerCone = coneAperture(1)*1e6/micronPerDegree;

% nCones = fov/degPerCone, and we make it a bit larger
nConesHRealSize = floor((hFov/degPerCone));
vFov = sceneGet(scene,'vfov');
nConesVRealSize = floor(vFov/degPerCone);

% Specify the relative densities of empty (K) and L,M,S cone ratios
rgbDensities = [1, 8, 4, 2];
rgbDensities = rgbDensities/sum(rgbDensities);

sz = [nConesVRealSize nConesHRealSize];
fprintf('Creating  %.0fx%.0f cone mosaic\n',nConesVRealSize,nConesHRealSize);

rSeed = 10;  % So we can always repeat this exactly
% An alternative call is
params.sz = sz;
params.rgbDensities = rgbDensities;
params.coneAperture = coneAperture;
params.rSeed = rSeed;
sensor = sensorCreate('human',[],params);

% Alternative way to make this call is:
%
% [sensor, xy, coneType, rSeed] = ...
%     sensorCreateConeMosaic(sensorCreate, sz,rgbDensities,coneAperture,rSeed);

% View the cone mosaic
sensorConePlot(sensor);
title('Cone mosaic');

% Check that the FOVs are about equal for the scene and the sensor.
fprintf('Sensor fov: %f\n',sensorGet(sensor,'fov',scene,oi));
fprintf('Scene fov: %f\n',sceneGet(scene,'fov'));

%% Adjust pixel properties for human - We need a rationale for values.
%  Writing these kinds of programs makes it clear that we need better
%  parameters for these aspects of the cone properties.  Fred Rieke, to the
%  rescue, one hopes.
voltageSwing = 0.2; %

pixel = sensorGet(sensor,'pixel');
pixel = pixelSet(pixel,'darkVoltage',0);
pixel = pixelSet(pixel,'readNoiseVolts',0.0005);
pixel = pixelSet(pixel,'voltageSwing',0.02);

sensor = sensorSet(sensor,'pixel',pixel);
sensor = sensorCompute(sensor,oi);
vcAddAndSelectObject(sensor);
sensorWindow;

%% Show the cone absorption counts across a horizontal image line
% The absorptions in the L,M, and S are shown as red, green and blue.  The
% black curve at the top is a measure of the typical noise we have modeled
% in the pixel and sensor parameters.  Notice the very low contrast in the
% S-cones, due to chromatic aberration.
f = sensorPlotLine(sensor,[],'photons','space',[1 116]);

%% To retrieve and plot the L,M and S cone absorptions you can use this:
%  The absorption histograms are variable in part because of photon noise,
%  but in this implementation there is also some dark current and read
%  noise that we put into the photon noise.  It is possible to set the
%  properties of the sensor to be ideal, so that there is only photon
%  noise.

vcNewGraphWin;
fColor = {'red','green','blue'};
for ii=1:3
    cData = sensorGet(sensor,'photons',ii+1);
    histogram(cData,30,'FaceColor',fColor{ii});
    hold on
end
hold off

%% Create a dichromatic sensor mosaic
%  One can experiment with all kinds of different mosaic properties to
%  understand the implications of various densities, sensitivies, and noise
%  characteristics.
%  Here, I illustrate how to create a dichromatica retina. The dichromacy
%  is created because the L cone slot is 0 in rgbDensities. We could do
%  experiments trying to understand the consequences for spatial resolution
%  of missing a cone class.

params.sz =  [200 200];  % A little smaller
rgbDensities = [0 0 2 1];
rgbDensities = rgbDensities/sum(rgbDensities);
params.rgbDensities = rgbDensities;
sensor = sensorCreate('human',[],params);

sensorConePlot(sensor); title('Protan cone mosaic');

%% END
