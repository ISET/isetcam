function [theDisplay, rgbPrimaries, illEnergy] = displayReflectance(ctemp)
% Create a natural surface reflectance display for a given color temp ill
%
% Synopsis
%   [theDisplay, rgbPrimaries, illEnergy] = displayReflectance(ctemp)
%
% Input
%   ctemp - Illuminant color temperature (degrees Kelvin)
%
% Output
%  theDisplay
%  rgbPrimaries
%  illEnergy
%
% See also
%  s_displaySurfaceReflectance

% Examples:
%{
 ctemp = 3000;
 theD = displayReflectance(ctemp);
 displayPlot(theD,'spd');
%}
%{
 ctemp = 6500;
 theD = displayReflectance(ctemp);
 displayPlot(theD,'spd');
%}
%{
 
%}

%%
wave = 400:1:700;
basis = ieReadSpectra('reflectanceBasis.mat',wave);
basis(:,1) = -1*basis(:,1);
% plotReflectance(wave,basis(:,1:3));

%% Load the standard CIE daylight illuminant

% Loaded as energy.
illEnergy = blackbody(wave,ctemp,'energy');

%% Radiance basis - 3D
%
% The radiance basis must be  described by these three columns if the light
% is D65 and the surfaces are within the space spanned by the first three
% natural reflectance function bases.

radianceBasis = diag(illEnergy(:,1))*basis(:,1:3);
% plotRadiance(wave,radianceBasis);

%% Find the sRGB XYZ values

% Suppose a point in the rgb file we read is represented by the row vector,
%
%    p = [R,G,B]. 
%
% The matrix lrgb2xyz transforms the row vector, XYZ = p*lrgb2xyz;
%
lrgb2xyz = colorTransformMatrix('lrgb2xyz');

% Transposing the matrix gives us the XYZ values of the XYZ values of the
% sRGB display in the columns.
%
lXYZinCols = lrgb2xyz';

%% Find a 3x3 T such that the reflectance display and sRGB primaries match
%
% The match is with respect to XYZ.  The matrix lXYZinCols has the sRGB
% primaries in the columns.  So we want T that satisfies
%
%    lXYZinCols = XYZ'*radianceBasis*T
%
%  We will assign the reflectance-display primaries to be radianceBasis*T
%

% Read in the XYZ functions with respect to energy.
XYZ = ieReadSpectra('XYZEnergy.mat',wave);

T = pinv(XYZ'*radianceBasis)*lXYZinCols;

% We use these as the primaries of the theoretical reflectance display.
rgbPrimaries = radianceBasis*T;

%% Now build the display
theDisplay = displayCreate('default');
theDisplay = displaySet(theDisplay,'wave',wave);
theDisplay = displaySet(theDisplay,'spd',rgbPrimaries);

%% Set the display to a luminance of 100

peakL = displayGet(theDisplay,'peak luminance');

% Scale the primaries and the illuminant.  Before this scaling,
%
%   reflectanceBasis = diag(1./illEnergy)*rgbPrimaries
%
theDisplay = displaySet(theDisplay,'spd',rgbPrimaries*(100/peakL));

% To preserve the reflectance
%
%  reflectanceBasis = diag(1./(illEnergy*(100/peakL))*rgbPrimaries*100/peakL
%
illEnergy = illEnergy*(100/peakL);

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
theDisplay = displaySet(theDisplay,'gamma',g);

theDisplay = displaySet(theDisplay,'name',sprintf('Natural (ill %dK)',ctemp));

end
