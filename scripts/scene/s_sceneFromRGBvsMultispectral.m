%% How well does sceneFromRGB perform?
%
% Compare a hyperspectral scene estimated from an *RGB image* to the
% original *hyperspectral* scene.
% 
% * Read in a multispectral scene and create an sRGB image we
% should have a script that is s_multispectral2RGB include the
% gamma rendering
% * Read in the RGB image and estimate multispectral image
% convert to linear given known gamma convert to multispectral
% image (see s_sceneFromMultispectral.m)
% * Compare the estimated multispectral scene to the original
% multispectral scene comparison of spectral reflectances
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

ieAddObject(scene); sceneWindow;  % Display the scene in the scene window

%% Obtain the sRGB data from the scene

rgb = sceneGet(scene,'rgb');
meanL = sceneGet(scene,'mean luminance');

% Load a display and convert the sRGB to a scene
displayCalFile = 'LCD-Apple.mat';
load(displayCalFile,'d');
sceneRGB = sceneFromFile(rgb,'rgb',meanL,d);
sceneRGB = sceneSet(sceneRGB,'name','From RGB');
% ieAddObject(sceneRGB); sceneWindow;

% Now convert the illuminant
wave = sceneGet(sceneRGB,'wave');
bb = blackbody(wave,6500);
sceneRGB = sceneAdjustIlluminant(sceneRGB,bb);
sceneRGB = sceneAdjustLuminance(sceneRGB,meanL);

sceneRGB = sceneSet(sceneRGB,'name','From RGB 6500K');
ieAddObject(sceneRGB); sceneWindow;

%%