%% s_displaySurfaceReflectance
%
% Create a meaningful surface reflectance display 
%
%  Such that an sRGB image will have D65 light and surface reflectance
%  basis functions.
%

%% Load up the reflectance basis

wave = 400:1:700;
basis = ieReadSpectra('reflectanceBasis.mat',wave);
basis(:,1) = -1*basis(:,1);

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

%% Save the reflectance-display

% We will use this as the default display for sceneFromFile
fname = fullfile(isetRootPath,'data','displays','reflectance-display');
save(fname,'d');

%%  Try it out

thisWave = 400:10:700;
scene = sceneFromFile('FruitMCC_6500.tif','rgb',50,'reflectance-display',thisWave);
sceneWindow(scene);

%% END






