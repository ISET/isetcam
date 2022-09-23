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
% The weights of the basis for a reflectance of 1's
% ones = basis*y
% y = basis(:,1:3)\ones(size(basis,1),1);
% plotReflectance(wave,basis(:,1:3)*y)
% plotReflectance(wave,basis(:,1:3))
%% Load the blackbody radiator at the specified color temperature

illEnergy = blackbody(wave,ctemp,'energy');

%% The spectral radiance basis for this illuminant
%
% The radiance basis must be  described by these three columns if the light
% is D65 and the surfaces are within the space spanned by the first three
% natural reflectance function bases.

radianceBasis = diag(illEnergy(:,1))*basis(:,1:3);
% plotRadiance(wave,radianceBasis);
% plotRadiance(wave,sum(radianceBasis,2));
% plotRadiance(wave,illEnergy)
%


%% Find the sRGB XYZ values

% Suppose a point in the rgb file is represented by the row vector,
%
%    p = [R,G,B]. 
%
% The matrix lrgb2xyz transforms the row vector, XYZ = p*lrgb2xyz;
%
lrgb2xyz = colorTransformMatrix('lrgb2xyz');

% The transpose of this matrix puts the XYZ values of the sRGB display
% in the columns.  So the XYZ of (1,0,0) is the first column of
% lXYZinCols.
%
lXYZinCols = lrgb2xyz';

%% Find a 3x3 (T) to match the reflectance display and sRGB primaries
%
% The match is with respect to XYZ.  The matrix lXYZinCols has the sRGB
% primaries in the columns.  So we want T that satisfies
%
%    lXYZinCols = XYZ'*radianceBasis*T
%
%  By making the reflectance-display primaries radianceBasis*T, the
%  lRGB (linearized sRGB) values produce a radiance whose XYZ values
%  in the reflectance display match the lRGB values when they are in
%  an sRGB display.
%

% Read in the XYZ functions with respect to energy.
XYZ = ieReadSpectra('XYZEnergy.mat',wave);

T = pinv(XYZ'*radianceBasis)*lXYZinCols;

% We use these as the primaries of the theoretical reflectance
% display.  They span the space of illuminant*refBasis, and they are
% adjusted so that rgbPrimaries*lRGB has the same XYZ as lRGB on an
% sRGB display.
rgbPrimaries = radianceBasis*T;

%% Now build the display
theDisplay = displayCreate('default');
theDisplay = displaySet(theDisplay,'wave',wave);
theDisplay = displaySet(theDisplay,'spd',rgbPrimaries);

%% Set the display primaries to a peak luminance of 100

% Scale the primaries and the illuminant.  Before this scaling,
%
%   reflectanceBasis = diag(1./illEnergy)*rgbPrimaries
%
peakL = displayGet(theDisplay,'peak luminance');
rgbPrimaries = rgbPrimaries*(100/peakL);
theDisplay = displaySet(theDisplay,'spd',rgbPrimaries);

%% Scaling the illuminant for a scene
%
% When we use sceneFromFile and theDisplay, we would like to set the
% scene illuminance to be illEnergy.  This differs from the usual
% case, when we set the illuminant to be the SPD of the sum of the
% primaries.  
% 
% In this case, we want the scene illuminant to be the blackbody
% radiator for this color temperature.  We have the relative amount as
% illEnergy already.  But this curve needs to be scaled so that when
% the display energy is illEnergy, the estimated reflectance will be
% roughly 1's.
%
%{
% Suppose spd is the scene radiance

 spd = rgbPrimaries*y 
     = radianceBasis*T*y
     = diag(illEnergy)*refBasis*T*y

% When spd is illEnergy, we would like refBasis*T*Y to be close to 1's
y = (rgbPrimaries'*rgbPrimares)^-1*rgbPrimaries'*illEnergy

% The level of the illEnergy in the scene should satisfy this
% relationship with the rgbPrimaries 
1's = rgbPrimaries*(rgbPrimaries'*rgbPrimaries)^-1*rgbPrimaries'*illEnergy

% We calculate the current illEnergy level and scale to make the
% result close to 1's
%}

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
