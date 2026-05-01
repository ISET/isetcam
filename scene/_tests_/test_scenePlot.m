function tests = test_scenePlot()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
% Test the scenePlot function calls
%

%%
ieInit;

%% Initialize data
scene = sceneCreate; 

% Test cases
scenePlot(scene,'luminance mesh linear');
scenePlot(scene,'luminance mesh log');

rows = round(sceneGet(scene,'rows')/2);
scenePlot(scene,'hline radiance',[1,rows]);
drawnow;

%% A region of interest

% Fourier Transform of the luminance in the row
uData = scenePlot(scene,'luminance fft hline',[1,rows]);
drawnow;

%% Radiance image with an overlaid spatial grid
gridSpacing = 21;
scenePlot(scene,'radiance image with grid',[],gridSpacing);
scenePlot(scene,'illuminant photons roi');
uData = scenePlot(scene,'depth map');
drawnow;

%% Reflectance data from an ROI
roiRect = [26    40    13    16];
uData = scenePlot(scene,'reflectance roi',roiRect);
scenePlot(scene,'chromaticity',roiRect);
drawnow;

%%
roiRect = [6    51     8    12];
uData = scenePlot(scene,'reflectance',roiRect);
scenePlot(scene,'chromaticity',roiRect);
drawnow;

%%
scenePlot(scene,'illuminant photons');

%% END

end
