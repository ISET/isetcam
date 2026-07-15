%% Scene geometry operations: combine, crop, insert, resize, and resample
%
% This example shows geometry-aware operations on scenes and prints key
% geometry/photometry checks after each step.
%
% See also: sceneCombine, sceneCrop, sceneInsert, sceneSet, sceneSpatialResample
%
% Copyright Imageval Consulting, LLC, 2026

%%
ieInit

%% Build two scenes with matched size for combining
sceneA = sceneCreate('checkerboard',16,8,'ep');
sceneA = sceneSet(sceneA,'resize',[64 64]);
sceneA = sceneSet(sceneA,'fov',1);
sceneB = sceneCreate('frequency orientation');
sceneB = sceneSet(sceneB,'resize',sceneGet(sceneA,'size'));
sceneB = sceneSet(sceneB,'fov',1);

%% Horizontal and vertical combine
sceneH = sceneCombine(sceneA,sceneB,'direction','horizontal');
sceneV = sceneCombine(sceneA,sceneB,'direction','vertical');

fprintf('Horizontal combine size: [%d %d], FOV: %.2f deg\n', ...
    sceneGet(sceneH,'rows'),sceneGet(sceneH,'cols'),sceneGet(sceneH,'fov'));
fprintf('Vertical combine size:   [%d %d], FOV: %.2f deg\n', ...
    sceneGet(sceneV,'rows'),sceneGet(sceneV,'cols'),sceneGet(sceneV,'fov'));

sceneWindow(sceneH);
sceneWindow(sceneV);

%% Crop a rectangular region from the horizontal combined scene
cropRect = [20 12 63 31];  % [x y width height]
[sceneCropped, rectOut] = sceneCrop(sceneH,cropRect);

fprintf('Crop rect used: [%d %d %d %d]\n',rectOut(1),rectOut(2),rectOut(3),rectOut(4));
fprintf('Cropped size:   [%d %d]\n',sceneGet(sceneCropped,'rows'),sceneGet(sceneCropped,'cols'));

sceneWindow(sceneCropped);

%% Insert a resized scene patch into a uniform base scene
baseScene = sceneCreate('uniformee',64);
baseScene = sceneSet(baseScene,'fov',1);
insertScene = sceneCreate('slantedBar',128,2.0);
insertScene = sceneSet(insertScene,'resize',[16 16]);
insertScene = sceneSet(insertScene,'fov',1);
insertPosition = [17 25];  % [row col]

sceneInserted = sceneInsert(baseScene,insertScene,insertPosition);

fprintf('Insert patch size: [%d %d] at row/col [%d %d]\n', ...
    sceneGet(insertScene,'rows'),sceneGet(insertScene,'cols'), ...
    insertPosition(1),insertPosition(2));

sceneWindow(sceneInserted);

%% Resize while preserving horizontal FOV and width
sceneResized = sceneSet(sceneInserted,'resize',[72 96]);

fprintf('Resize: [%d %d] -> [%d %d]\n', ...
    sceneGet(sceneInserted,'rows'),sceneGet(sceneInserted,'cols'), ...
    sceneGet(sceneResized,'rows'),sceneGet(sceneResized,'cols'));
fprintf('FOV preserved: %.4f -> %.4f deg\n', ...
    sceneGet(sceneInserted,'fov'),sceneGet(sceneResized,'fov'));
fprintf('Mean luminance: %.4f -> %.4f cd/m^2\n', ...
    sceneGet(sceneInserted,'mean luminance'),sceneGet(sceneResized,'mean luminance'));

sceneWindow(sceneResized);

%% Spatial resample by target spacing (microns)
currentSR = sceneGet(sceneResized,'spatial resolution','um');
dx = max(currentSR)*2;
sceneResampled = sceneSpatialResample(sceneResized,dx,'um');
sr = sceneGet(sceneResampled,'spatial resolution','um');

fprintf('Resample target dx: %.2f um, resulting spacing [%.2f %.2f] um\n', ...
    dx,sr(1),sr(2));
fprintf('Resampled size: [%d %d]\n',sceneGet(sceneResampled,'rows'),sceneGet(sceneResampled,'cols'));

sceneWindow(sceneResampled);

%%