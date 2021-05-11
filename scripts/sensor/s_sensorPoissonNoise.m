%% Poisson scaling
%

%%  Suppose these are the photon absorptions - without any other noise

lambda = logspace(1, 3, 10);
nSamp = 100;
useSeed = 1;
photons = zeros(numel(lambda), nSamp);
for ii = 1:numel(lambda)
    photons(ii, :) = poissrnd(lambda(ii), nSamp, useSeed);
end

%%  In that case, we have the mean and standard deviations as follows

mPhotons = mean(photons, 2);
sPhotons = std(photons, 0, 2);
ieNewGraphWin;
loglog(mPhotons, sPhotons, 'k--');
axis equal; grid on

%% Suppose we have a conversion gain of 100 photons per dv

% No other noise
dvPerPhoton = 0.01;
dv = photons * dvPerPhoton;

mDV = mean(dv, 2);
sDV = std(dv, 0, 2);
rootDV = sqrt(mDV);

ieNewGraphWin;
loglog(mDV, sDV, 'k--', mDV, rootDV, 'b--')
axis equal; grid on

%% Create a Sony sensor and run some simulations

sensor = sensorCreate('imx363');
sensor = sensorSet(sensor, 'row', 500);
sensor = sensorSet(sensor, 'col', 500);

scene = sceneCreate('macbeth');
scene = sceneSet(scene, 'fov', 10);
oi = oiCreate('diffraction limited');

sensor = sensorSet(sensor, 'exp time', 0.016);

oi = oiCompute(oi, scene);
sensor = sensorCompute(sensor, oi);
sensorWindow(sensor);

% [col row width height], (x,y,width,height)
rect = [186, 340, 44, 46];
sensor = sensorSet(sensor, 'roi', rect);
sensorGet(sensor, 'roi rect')
dv = sensorGet(sensor, 'roi dv', rect);

nanmean(dv)
nanstd(dv)

%% END
