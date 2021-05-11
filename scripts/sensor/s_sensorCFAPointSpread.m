%% Show the CFA image of a point and line for different f/# lenses
%
%
% Copyright Imageval Consulting, LLC 2016

%%
ieInit

%%
scene = sceneCreate('point array');

% Make the points bluish
wave = sceneGet(scene, 'wave');
scene = sceneAdjustIlluminant(scene, blackbody(wave, 8000));
scene = sceneSet(scene, 'fov', 2);

oi = oiCreate('diffraction limited');

pSize = [1.4, 1.4] * 1e-6; % Pixel size in meters
sensor = sensorCreate;
sensor = sensorSet(sensor, 'pixel size constant fill factor', pSize);
sensor = sensorSet(sensor, 'auto exposure', true);

%% Loop on fnumber and crop out the image

rect = [32, 24, 11, 11];
x = [0:rect(3)] * pSize(1);
x = x - mean(x(:));
x = x * 1e6;
vcNewGraphWin;
panel = 1;
for ff = [2, 4, 8, 12]
    oi = oiSet(oi, 'optics fnumber', ff);
    oi = oiCompute(oi, scene);
    sensor = sensorCompute(sensor, oi);

    img = sensorData2Image(sensor);
    img = imcrop(img, rect);
    subplot(2, 2, panel)
    imagesc(x, x, img);
    axis image;
    title(sprintf('F/# %d', ff));
    panel = panel + 1;
    xlabel('Position (um)');
end

%%
% ieAddObject(scene); sceneWindow;
% ieAddObject(oi); oiWindow;
% ieAddObject(sensor); sensorWindow;
