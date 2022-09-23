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

%%  Read in the natural surface reflectance basis

wave = 400:1:700;
basis = ieReadSpectra('reflectanceBasis.mat',wave);
basis(:,1) = -1*basis(:,1);
% plotReflectance(wave,basis(:,1:3));

%% Load the blackbody radiator at the specified color temperature

illEnergy = blackbody(wave,ctemp,'energy');

%% The spectral radiance basis for this illuminant
%
% The radiance basis must be  described by these three columns if the light
% is D65 and the surfaces are within the space spanned by the first three
% natural reflectance function bases.

radianceBasis = diag(illEnergy(:,1))*basis(:,1:3);
% plotRadiance(wave,radianceBasis);

%% To preserve the reflectance scale, we need to scale the illuminant.
%
% In principle, a reflectance of 1's should be represented by a radiance of
% illEnergy.  How do we set the scale?
%
%  reflectanceBasis = diag(1./(illEnergy*(100/peakL))*rgbPrimaries*100/peakL
%
illEnergy = illEnergy*(100/peakL);


%% Find the sRGB XYZ values

% Suppose a point in the rgb file is represented by the row vector,
%
%    p = [R,G,B]. 
%
% The matrix lrgb2xyz transforms the row vector, XYZ = p*lrgb2xyz;
%
lrgb2xyz = colorTransformMatrix('lrgb2xyz');

% Transposing the matrix gives us the XYZ values of the sRGB display in the
% columns.
%
lXYZinCols = lrgb2xyz';

%% Find a 3x3 T to match the reflectance display and sRGB primaries
%
% The match is with respect to XYZ.  The matrix lXYZinCols has the sRGB
% primaries in the columns.  So we want T that satisfies
%
%    lXYZinCols = XYZ'*radianceBasis*T
%
%  By making the reflectance-display primaries to be radianceBasis*T, the
%  lRGB (linearized sRGB) values produce a radiance that matches the XYZ
%  values in the new display that they would have produced in the sRGB
%  display.
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
% Scale the primaries and the illuminant.  Before this scaling,
%
%   reflectanceBasis = diag(1./illEnergy)*rgbPrimaries
%
peakL = displayGet(theDisplay,'peak luminance');
theDisplay = displaySet(theDisplay,'spd',rgbPrimaries*(100/peakL));

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
