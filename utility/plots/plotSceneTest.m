% Test the plotScene function calls
%
% (BW) Imageval Consulting, 2013
%

%% Initialize data
scene = sceneCreate;
vcAddAndSelectObject(scene);
sceneWindow;

% Test cases
plotScene(scene, 'luminance mesh linear');
plotScene(scene, 'luminance mesh log');

rows = round(sceneGet(scene, 'rows')/2);
plotScene(scene, 'hline radiance', [1, rows]);

%% A region of interest

% Fourier Transform of the luminance in the row
uData = plotScene(scene, 'luminance fft hline', [1, rows]);

%% Radiance image with an overlaid spatial grid
gridSpacing = 21;
plotScene(scene, 'radiance image with grid', [], gridSpacing)
plotScene(scene, 'illuminant photons roi')
uData = plotScene(scene, 'depth map');

%% Reflectance data from an ROI
roiRect = [26, 40, 13, 16];
uData = plotScene(scene, 'reflectance roi', roiRect);
plotScene(scene, 'chromaticity', roiRect)

%%
roiRect = [6, 51, 8, 12];
uData = plotScene(scene, 'reflectance', roiRect);
plotScene(scene, 'chromaticity', roiRect)

%%
plotScene(scene, 'illuminant photons');

%% End
