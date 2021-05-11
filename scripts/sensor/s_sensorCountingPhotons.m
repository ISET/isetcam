%% Calculate the number of photons at a pixel
%
% We learn a great deal about image quality and noise limits by counting
% the (*Poisson*) arrival of photons at each pixel. Because ISET uses
% physical units throughout, we can easily calculate the number of incident
% photons, or stored electrons, at the sensor.
%
% See also:  sceneFromFile, displayCreate, scenePlot, ieDrawShape,
% oiCompute, sensorCompute
%
% Copyright Imageval Consulting, LLC 2011

%%
ieInit

%% Load up an example scene

sFile = fullfile(isetRootPath, 'data', 'images', 'rgb', 'hats.jpg');
scene = sceneFromFile(sFile, 'rgb', 100, displayCreate('OLED-Sony'));
scene = sceneAdjustIlluminant(scene, 'D65.mat');

ieAddObject(scene);
sceneWindow;

%% Show a region of interest on the scene

% You can get the roiRect using get(gcf,'userdata')
roiRect = [64, 64, 16, 16];
ieDrawShape(scene, 'rectangle', roiRect);

%% Plot the mean spectral radiance in the roi

[udata, f] = scenePlot(scene, 'radiance photons roi', roiRect);

% The sum of the mean number of photons from all the wavelengths
% q/s/sr/nm/m2
t = sprintf('Sum of photons across wavelengths %.2e\n', sum(udata.photons(:)));
title(t);

%% Create spectral irradiance at the sensor for optics with a range of f#

oi = oiCreate; % Basic diffraction-limited optics

% Region in the OI we will measure
roiRect = [291, 202, 16, 23];

% Loop for different f numbers
fnumbers = [2, 4, 8, 16, 32];

% Store the photon count here
totalQ = zeros(1, length(fnumbers));

for ff = 1:length(fnumbers)
    oi = oiSet(oi, 'optics fnumber', fnumbers(ff));
    oi = oiCompute(scene, oi);
    spectralIrradiance = oiGet(oi, 'roi mean photons', roiRect);
    totalQ(ff) = sum(spectralIrradiance);
end

%% Plot one spectral irradiance

vcNewGraphWin;
plot(oiGet(oi, 'wave'), spectralIrradiance, '--');
grid on
xlabel('Wavelength (nm)');
ylabel('Photons/s/nm/m^2');
title(sprintf('Spectral irradiance (f# %d)', fnumbers(end)));

%% Plot the number of photons as a function of f#

vcNewGraphWin;
loglog(fnumbers, totalQ, '-o');
grid on;
xlabel('f#'); ylabel('Photons/s/m^2')
title('Total photons vs. f#')

%%
