%% Calculate the number of photons at a sensor surface
%
% We learn a great deal about image quality and noise limits by counting
% the (*Poisson*) arrival of photons at each pixel. Because ISET uses
% physical units throughout, we can easily calculate the number of incident
% photons, or stored electrons, at the sensor.
%
% See also:  sceneFromFile, displayCreate, scenePlot, ieDrawShape,
% oiCompute, sensorCompute
%
% Used in FISE-git
%

%%
ieInit

%% Load up a simple uniform scene, just to count

% To just count, it is easy to use a uniform scene.  The luminance
% level is set to A moderately lit living room at night: Imagine a
% room with a few lamps on, but not overly bright. If you're reading a
% book with a standard table lamp, the page might be closer to 50-100
% nits, but the overall average luminance of the entire room (walls,
% furniture, shadows) could easily be around 10 nits.
scene = sceneCreate('uniform equal photon',[512 512]);
scene = sceneSet(scene,'mean luminance',10);

%% Create spectral irradiance at the sensor for optics with a range of f#

oi = oiCreate('diffraction limited');  % Basic diffraction-limited optics

% Region in the OI we use to measure
roiRect = [291 202 16 23];

% Loop for different f numbers
fnumbers = 2:16;

% Store the photon count here
totalQ = zeros(1,length(fnumbers));

% Store the aperture diameter here
apertureD = zeros(size(totalQ));

for ff = 1:length(fnumbers)
    oi = oiSet(oi,'optics fnumber',fnumbers(ff));
    oi = oiCompute(oi,scene);
    apertureD(ff) = oiGet(oi,'optics aperture diameter','mm');
    spectralIrradiance = oiGet(oi,'roi mean photons',roiRect);
    totalQ(ff) = sum(spectralIrradiance);
end

%% Plot one spectral irradiance

ieFigure;
plot(oiGet(oi,'wave'),spectralIrradiance,'--');
grid on
xlabel('Wavelength (nm)'); ylabel('Photons/s/nm/m^2');
title(sprintf('Spectral irradiance (f# %d)',fnumbers(end)));

%% Plot the number of photons as a function of f#
% {
% Per second per square micron
ieFigure;
plot(fnumbers,totalQ*1e-12,'-o');
grid on;
xlabel('F/#'); ylabel('Photons/s/{um}^2')
title('Total photons vs. f#')
%}

%%
ieFigure;
% Suppose a micron pixel aperture and a 50 ms time period
sFactor = (1e-6)^2*50e-3;
plot(apertureD,totalQ*sFactor,'-o');
grid on;
xlabel('Aperture diameter (mm)'); ylabel('Photons/{50 ms}/{um}^2')

%% Signal-to-noise

% How many standard deviations of signal at the level?  This tells us
% how many steps of intensity we can reliably discriminate.
SNR = totalQ*sFactor ./ sqrt(totalQ*sFactor);

ieFigure;
plot(apertureD,SNR,'-o');
grid on;
xlabel('Aperture diameter (mm)'); ylabel('Signal-to-noise ratio')

%% Signal-to-noise

ieFigure;
plot(fnumbers,SNR,'-o');
grid on;
xlabel('F/#'); ylabel('Signal-to-noise ratio')

%% Poisson scaling in digital values
%
% Inspect how photon shot noise maps into digital values after applying
% a linear conversion gain.

lambda = logspace(1,3,10);
nSamp  = 100;
useSeed = 1;
photons = zeros(numel(lambda),nSamp);
for ii = 1:numel(lambda)
    photons(ii,:) = poissrnd(lambda(ii),nSamp,useSeed);
end

mPhotons = mean(photons,2);
sPhotons = std(photons,0,2);
ieFigure;
loglog(mPhotons,sPhotons,'k--');
axis equal; grid on
xlabel('Mean photons'); ylabel('Std photons')
title('Poisson scaling in photon counts')

% Example conversion gain from photons to digital values.
dvPerPhoton = 0.01;
dv = photons*dvPerPhoton;

mDV = mean(dv,2);
sDV = std(dv,0,2);
rootDV = sqrt(mDV);

ieFigure;
loglog(mDV,sDV,'k--',mDV,rootDV,'b--');
axis equal; grid on
xlabel('Mean digital value'); ylabel('Std digital value')
title('Poisson scaling after conversion gain')

%% Sensor ROI digital-value statistics

sensor = sensorCreate('imx363');
sensor = sensorSet(sensor,'row',500);
sensor = sensorSet(sensor,'col',500);

scene = sceneCreate('macbeth');
scene = sceneSet(scene,'fov',10);
oi = oiCreate('diffraction limited');
sensor = sensorSet(sensor,'exp time',0.016);

oi = oiCompute(oi,scene);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

% [col row width height], (x,y,width,height)
rect = [186 340 44 46];
sensor = sensorSet(sensor,'roi',rect);
dvRoi = sensorGet(sensor,'roi dv',rect);

fprintf('ROI mean dv: %.3f\n',nanmean(dvRoi(:)));
fprintf('ROI std dv:  %.3f\n',nanstd(dvRoi(:)));

%%