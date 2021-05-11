%% Examples of diffraction limited optics calculations.
%
% See also:  oiCreate, oiCompute, oiSet, oiPlot
%
% (c) Imageval Consulting, LLC, 2012

%%
ieInit

%% Create a point array scene
scene = sceneCreate('point array');
scene = sceneSet(scene, 'h fov', 1); % Degrees
ieAddObject(scene);
sceneWindow;

%% Compute the irradiance
oi = oiCreate;
oi = oiCompute(oi, scene);
oi = oiSet(oi, 'name', 'Default f/#');
ieAddObject(oi);
oiWindow;

%% Create diffraction limited optics with f/# of 12

% Current f number
oiGet(oi, 'optics f number')

% The larger f/# blurs the image more
% It has larger depth of field, however, because the aperture is smaller.
oi = oiSet(oi, 'optics fnumber', 12);
oi = oiSet(oi, 'name', 'Large f/#');
oi = oiCompute(oi, scene);

ieAddObject(oi);
oiWindow;

%% Plot the point spread
oiPlot(oi, 'psf 550');

%% Check the inter-related parameters
p = oiGet(oi, 'optics pupil diameter', 'mm')
f = oiGet(oi, 'optics focal length', 'mm')
f / p

%% Show the diffraction-limited blur dependence on wavelength

uData = oiPlot(oi, 'ls wavelength');
title(sprintf('F/# = %.0d', oiGet(oi, 'optics f number')))

%% Look at the data structure returned by oiPlot
uData

%%