%% Spatial-CIELAB (SCIELAB) metric calculation using ISET.
%
% The first section shows how to read an RGB image into a scene. Then, we
% calculate the scielab dieIifferences between two scenes.  The data in the
% scene depend on the display that is used to interpret the RGB data.
%
% The second section expands on the calculation, showing the steps in more
% detail. It illustrates the conversion of the RGB data into XYZ data from
% the calibrated display and it also shows how to set up the scielab()
% arguments in the call.
%
% See Also: scielabRGB, displayGet
%
% Copyright ImagEval, LLC, 2011

%
ieInit

%% Overview of the scielab call

% Set up to read an image and a JPEG compressed version of it
file1 = fullfile(isetRootPath, 'data','images','RGB','hats.jpg');
file2 = fullfile(isetRootPath, 'data','images','RGB','hatsC.jpg');

% We will treat the two images as if they are on a CRT display seen from 12
% inches.
vDist = 0.3;          % 12 inches
dispCal = 'LCD-Apple.mat';   % Calibrated display

%% Spatial scielab reads the RGB files and calibrated display

% Convert the RGB files to a scene and then call scielabRGB
% The returns are an error image and two scenes containing the two images
% The display variable is the implicit display we used to transform the RGB
% images into the spectral image.  It does nt play a further role.
[eImage,scene1,scene2,display] = scielabRGB(file1, file2, dispCal, vDist);

% Show the RGB images as scenes. This illustrates how the RGB data were
% converted to SPDs using the calibrated display
ieAddObject(scene1);
ieAddObject(scene2);sceneWindow;

imageMultiview('scene',[1 2],true);


%% End
