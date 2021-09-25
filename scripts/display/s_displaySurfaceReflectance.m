%% s_displaySurfaceReflectance
%
%  Create a display so that an sRGB image presented on this display will
%  be interpreted as a D65 light with surface reflectance basis functions
%  matching the 3 basis functions of natural surfaces stored in
%  reflectanceBasis.mat.
%

%% Load up the reflectance basis

wave = 400:1:700;
basis = ieReadSpectra('reflectanceBasis.mat',wave);
basis(:,1) = -1*basis(:,1);
% plotReflectance(wave,basis(:,1:3));

%% Load up D65

% A little worried about photons versus energy here.  I think it is energy.
% And that would be good.
d65 = ieReadSpectra('D65.mat',wave);
% plotRadiance(wave,d65);

%% Radiance basis - 3D

radianceBasis = diag(d65)*basis(:,1:3);
plotRadiance(wave,radianceBasis);

%% Find the sRGB XYZ values

% Suppose a point is represented by the row vector, p = [R,G,B].
% The matrix lrgb2xyz transforms the row vector, p, to an output vector pT

lrgb2xyz = colorTransformMatrix('lrgb2xyz');

lXYZinCols = lrgb2xyz';

XYZ = ieReadSpectra('XYZEnergy.mat',wave);

%% We want to find T such that
%
%    lXYZinCols = XYZ'*radianceBasis*T
%
%  Then we will assign the display primaries to be radianceBasisT
%
T = pinv(XYZ'*radianceBasis)*lXYZinCols;

rgbPrimaries = radianceBasis*T;
plotRadiance(wave,rgbPrimaries);

%% Create the display

d = displayCreate('default');
d = displaySet(d,'wave',wave);
d = displaySet(d,'spd',rgbPrimaries);
displayPlot(d,'spd');
displayGet(d,'white xy')
peakL = displayGet(d,'peak luminance');

%% Set the display to a luminance of 100

rgbPrimaries = rgbPrimaries*(100/peakL);
d = displaySet(d,'spd',rgbPrimaries);
peakL = displayGet(d,'peak luminance');

%% Set the gamma of the display

% When we read in the image we will be applying the gamma correction for
% some display when we compute the radiance.  Maybe we should be using
% sRGB, which is something like 2.2 or 1.8.  For now, I inserted a measured
% gamma from an Apple display.

% Maybe we should set this based on the MCC gray series.  We know those
% reflectance levels and the horizontal luminance line should get at least
% the ratios on that right. (BW).
dApple = displayCreate('LCD-Apple');
g = displayGet(dApple,'gamma');
d = displaySet(d,'gamma',g);

%% Save the reflectance-display

% We will use this as the default display for sceneFromFile
fname = fullfile(isetRootPath,'data','displays','reflectance-display');
save(fname,'d');

%%  Try it out

thisWave = 400:10:700;
scene = sceneFromFile('FruitMCC_6500.tif','rgb',50,'reflectance-display',thisWave);
sceneWindow(scene);

%% END






