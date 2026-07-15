%% How well does sceneFromRGB perform?
%
% Compare a hyperspectral scene estimated from an *RGB image* to the
% original *hyperspectral* scene.
%
% Workflow:
%
% * Read a multispectral scene and render an sRGB image.
% * Reconstruct a multispectral estimate from the sRGB image.
% * Compare the reconstructed scene to the original.
%
% The bottom line is that
%
%  * the RGB and XYZ are preserved
%  * the illuminant is preserved, but
%  * the reflectances differ a little.
%
% See also:  sceneFromFile, sceneAdjustIlluminant, blackbody
%
% Copyright Imageval Consulting, LLC, 2015

%%
ieInit;

%%  Read in a multispectral scene

fullFileName = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs');
wList = 400:10:700;
scene = sceneFromFile(fullFileName,'multispectral',[],[],wList);
bb = blackbody(sceneGet(scene,'wave'),6500,'energy');
scene = sceneAdjustIlluminant(scene,bb);

sceneWindow(scene);  % Display the scene in the scene window

%% Obtain the sRGB data from the scene

rgb = sceneGet(scene,'rgb');
meanL = sceneGet(scene,'mean luminance');

% Load a display and convert the sRGB to a scene
displayCalFile = 'LCD-Apple.mat';
load(displayCalFile,'d');
sceneRGB = sceneFromFile(rgb,'rgb',meanL,d);
sceneRGB = sceneSet(sceneRGB,'name','From RGB');
% sceneWindow(sceneRGB);

% Now convert the illuminant
wave = sceneGet(sceneRGB,'wave');
bb = blackbody(wave,6500);
sceneRGB = sceneAdjustIlluminant(sceneRGB,bb);
sceneRGB = sceneAdjustLuminance(sceneRGB,meanL);

sceneRGB = sceneSet(sceneRGB,'name','From RGB 6500K');
sceneWindow(sceneRGB);

%%