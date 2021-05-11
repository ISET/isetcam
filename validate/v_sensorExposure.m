%% Validation of the sensorCompute routines
%
%  Create a standard sensor and a uniform input image.  Calculate how the
%  exposure times vary as we change the pixel size and the f-number of the
%  diffraction-limited imaging lens.  We use the number calculated in the
%  past as a validation that the basic calculations have not been changed
%  as we edit the software.
%
%
%  I should write a test that shows that doubling the pixel size, which
%  4x the area, should reduce the exposure time by 4x.  THere is a very
%  small error for the f/8 case as the pixel size increases.  It might be
%  the auto exposure routine or it might be some problem with accounting
%  for the spatial sampling between the optical image and the sensor.
%

%%
ieInit;

%%
uScene = sceneCreate('uniform equal energy', 256); % Uniform scene
uScene = sceneAdjustLuminance(uScene, 100);
oi = oiCreate; % Diffraction limited lens
pSize = [1, 1.5, 2, 2.5, 3] * 1e-6; % Microns

% Expected number of electrons. As we vary pixel size changes, the exposure
% duration varies to achieve this number of electrons, Computed Sept 21,
% 2020
expected = 5200; % updated 1/2021 to match new data, was 5200;
tolerance = 1; % One percent error allowed.  But that is too high, really.

%%  Sony IMX363 QE

% The defailt
sensor = sensorCreate('imx363');
sensor = sensorSet(sensor, 'fov', sceneGet(uScene, 'fov')/4, oi);

% In this case we still have gain and offset.  If we use -1 or -2 we turn
% off the gain and offset, so the numbers are quite different.
sensor = sensorSet(sensor, 'noise flag', 0);
sensor = sensorSet(sensor, 'auto exposure', true);

%%  The mean number is steadily increasing with pixel size.  Why?

fnumber = 8;
oi = oiSet(oi, 'optics fnumber', fnumber);
uOI = oiCompute(oi, uScene);

fprintf('\n\nSize Time (f/# %.1f)\n------\n', fnumber)
for ii = 1:length(pSize)
    thisSensor = sensorSet(sensor, 'pixel size constant fill factor', pSize(ii));
    thisSensor = sensorCompute(thisSensor, uOI);
    e = sensorGet(thisSensor, 'electrons');
    % assert( abs(((nanmean(e(:)) - expected)/100)) < tolerance);
    fprintf('%.2f %2f %f\n', pSize(ii)*1e6, sensorGet(thisSensor, 'exp time', 'sec'), nanmean(e(:)));
end

% sensorWindow(thisSensor);

%%  The mean number is not perfectly constant.  Why?
% Particularly odd when psize is 1 micron.  (BW).

fnumber = 2.4;
oi = oiSet(oi, 'optics fnumber', fnumber);
uOI = oiCompute(oi, uScene);

fprintf('\n\nSize Time (f/# %.1f)\n------\n', fnumber)
for ii = 1:length(pSize)
    thisSensor = sensorSet(sensor, 'pixel size constant fill factor', pSize(ii));
    thisSensor = sensorCompute(thisSensor, uOI);
    e = sensorGet(thisSensor, 'electrons');
    assert(abs(((nanmean(e(:)) - expected)/100)) < tolerance);
    fprintf('%.2f %2f %f\n', pSize(ii)*1e6, sensorGet(thisSensor, 'exp time', 'sec'), nanmean(e(:)));
end

%%  Big aperture.  Exposure times become quite short.
fnumber = 1.2;
oi = oiSet(oi, 'optics fnumber', fnumber);
uOI = oiCompute(oi, uScene);

fprintf('\n\nSize Time (f/# %.1f)\n------\n', fnumber)
for ii = 1:length(pSize)
    thisSensor = sensorSet(sensor, 'pixel size constant fill factor', pSize(ii));
    thisSensor = sensorCompute(thisSensor, uOI);
    e = sensorGet(thisSensor, 'electrons');
    assert(((nanmean(e(:)) - expected) / 100) < tolerance);
    fprintf('%.2f %2f %f\n', pSize(ii)*1e6, sensorGet(thisSensor, 'exp time', 'sec'), nanmean(e(:)));
end

%%
