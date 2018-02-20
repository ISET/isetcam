% Test the scenePlot function calls
%
% (BW) Imageval Consulting, 2013
%

%% Initialize data
scene = sceneCreate; ieAddObject(scene); sceneWindow;

% Test cases
scenePlot(scene,'luminance mesh linear');
scenePlot(scene,'luminance mesh log');

rows = round(sceneGet(scene,'rows')/2);
scenePlot(scene,'hline radiance',[1,rows]);

%% A region of interest

% Fourier Transform of the luminance in the row
uData = scenePlot(scene,'luminance fft hline',[1,rows]);

%% Radiance image with an overlaid spatial grid
gridSpacing = 21;
scenePlot(scene,'radiance image with grid',[],gridSpacing)
scenePlot(scene,'illuminant photons roi')
uData = scenePlot(scene,'depth map');

%% Reflectance data from an ROI
roiRect = [26    40    13    16];
uData = scenePlot(scene,'reflectance roi',roiRect);
scenePlot(scene,'chromaticity',roiRect)

%%
roiRect = [6    51     8    12];
uData = scenePlot(scene,'reflectance',roiRect);
scenePlot(scene,'chromaticity',roiRect)

%%
scenePlot(scene,'illuminant photons');

%%
