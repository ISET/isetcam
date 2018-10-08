function irradiance = RadianceToRetIrradiance(luminance,radiance,radianceS,pupilAreaMM,eyeSizeMM)
% irradiance = RadianceToRetIrradiance(luminance,radiance,radianceS,pupilAreaMM,eyeSizeMM)
%
% Perform the geometric calculations necessary to convert a measurement of source
% radiance to corresponding retinal irradiance. 
%
%   Input radiance should be in units of power/m^2-sr-wlinterval.
%   Input radianceS gives the wavelength sampling information.
%   Input pupilAreaMM should be in units of mm^2.
%   Input eyeSizeMM should be the length of the eye in mm.
%   Output irradiance is in units of power/um^2-sec-wlinterval.
%
%   Light power may be expressed in watts or quanta-sec or in your
%   favorite units.  Indeed, it may also be passed as energy rather
%   than power.  
%
% This conversion does not take absorption in the eye into account,
% as this is more conveniently foldeded into the spectral absorptance.
%
% See also: PupilAreaFromLum, IsomerizationsInEyeDemo.
%
% 7/10/03  dhb  Wrote it.

% Convert spectral units to watts/sr-mm^2-wlinterval
radianceMM = radiance*1e-6;

% Define factor to convert radiance spectrum to retinal irradiance in watts/mm^2-wlinterval.
% Commented out code shows the logic, which is short circuited by actual code.
% but is conceptually convenient for doing the calculation.
%  distanceToSourceMM = 100;
%  fractionfSphere = pupilAreaMM/4*pi*distanceToSourceMM^2;
%  pupilAreaSR = 4*pi*fractionOfSphere;
%  sourceAreaMM = (distanceToSourceMM^2)/(eyeSizeMM^2);
%  conversionFactor = pupilAreaSR*sourceAreaMM;
conversionFactor = pupilAreaMM/(eyeSizeMM^2);
irradianceMM = conversionFactor*radianceMM;

% Convert irradiance to units of quanta/um^2-sec-wlinterval
irradiance = irradianceMM*1e-6;
