%% s_initFont
%
% Test the font size change routines a bit
%
% (c) Imageval Consulting, LLC 2014

fSize = ieSessionGet('font size');
fprintf('Current font size %.0f\n', fSize);

%% Test changing the font size on a window

% Open a window
scene = sceneCreate;
ieAddObject(scene);
sW = sceneWindow;

%% Make the font size bigger and display

for ii = 8:2:16
    ieFontSizeSet(sW, ii);
    pause(1);
end

ieFontSizeSet(sW, 12);

%% Illustrate with oiWindow.  Otherwise same.

oi = oiCreate;
oi = oiCompute(oi, scene);
oiW = oiWindow;
for ii = 8:2:16
    ieFontSizeSet(oiW, ii);
    pause(1);
end

ieFontSizeSet(oiW, 12);

%% Changing the font size in one window changes all
ieFontSizeSet(oiW, 8);
oiWindow;
sceneWindow;

pause(2);
ieFontSizeSet(oiW, 12);
sceneWindow;

%% End