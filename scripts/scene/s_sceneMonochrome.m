%% Read in a monochrome image
%
% We show how to create a unispectral (single wavelength) scene
% from a monochrome image.
%
% See also:  displayCreate, sceneFromFile, sceneAdjustIlluminant
%
% Copyright ImagEval Consultants, LLC, 2005.

%%
ieInit;

%% Create a display
dispFile = 'crt';
d = displayCreate(dispFile);

%% Read the camera man image
fName = 'cameraman.tif';
scene = sceneFromFile(fName, 'monochrome', 100, dispFile);

% Adjust the unispectral to D65
bb = blackbody(sceneGet(scene, 'wave'), 6500, 'energy');
scene = sceneAdjustIlluminant(scene, bb);

ieAddObject(scene)
sceneWindow

%%