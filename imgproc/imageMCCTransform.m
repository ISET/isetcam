function T = imageMCCTransform(sensorQE,targetQE,illuminant,wave)
% Calculate sensor -> target linear transformation 
%
%  T = imageMCCTransform(sensorQE,targetQE,illuminant,wave)
%  
% sensorQE:   A matrix with columns containing the sensor spectral quantum
%             efficiencies. 
% targetQE:   A matrix with columns containing the spectral quantum efficiency
%             of the viewer; normally the human visual system (XYZ) but it
%             could be something else, such as an ideal camera. 
% illuminant: The name of the spectral power distribution of the light that
%             illuminates the Macbeth Color Checker. Default is D65. 
% wave:       The sample wavelengths
%
% Algorithm:  We compute a 3x3 transform, T, to convert from sensor space
%   to target space. The 3x3 is chosen to optimize the rendering of a
%   Macbeth color checker (MCC) under the specified illuminant.
%
%  The returned transform can be applied as:
%    img = imageLinearTransform(img,T);
%
% Example:
%
% PROGRAMMING TODO:
%  We should have a variety of ways of computing this linear transform,
%  including methods that account for known noise, use ridge methods,
%  search to minimize deltaE, and perhaps others.
%
%  We should be able to send in illuminant as a vector, not as a name.
%
%  We should be able to send in a set of surface reflectances in addition
%  to the illuminant.  The default could be the MCC, as now, but it should
%  not be required.
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Check arguments
if ieNotDefined('illuminant'), illuminant = 'D65'; end
if ieNotDefined('wave'), wave = 400:10:700; end

%% Read the MCC surface spectra and a target illuminant, say D65. 
% Combine them. 
fName  = fullfile(isetRootPath,'data','surfaces','macbethChart');
surRef = ieReadSpectra(fName,wave);

% The scale factor on the illuminant is not known.  Thus, the transform is
% only accurate up to an unknown scale factor.
illEnergy = ieReadSpectra(illuminant,wave);  % Should check for string or vector 
illQuanta = Energy2Quanta(wave,illEnergy);

%% Predicted sensor responses
%
% For the MCC surface reflectance functions under the illuminant
%
% The sensorMacbeth is an XW format.  
sensorMacbeth = (sensorQE'*diag(illQuanta)*surRef)';

% These are the desired sensor responses to the surface reflectance
% functions under the illuminant in the internal color space.  The
% sensorMacbeth is an XW format.  The target space should be correct for a
% photon (quanta) representation of the data.  That is, targetQE should be
% something like XYZQuanta or stockmanQuanta
targetMacbeth = (targetQE'*diag(illQuanta)*surRef)';

% This is the linear transformation that maps the sensor values into the
% target values, as illustrated in the comment below.  Should be calculated
% with a backslash, not this way.  Also, should deal with noise
% characteristics if possible.
T = pinv(sensorMacbeth)*targetMacbeth;

%% Test code
% pred = sensorMacbeth*T; 
% predImg = XW2RGBFormat(pred,6,4);
% figure; title('mcc')
% subplot(1,2,1), imagescRGB(imageIncreaseImageRGBSize(predImg,20));
% desiredImg = XW2RGBFormat(targetMacbeth,6,4);
% subplot(1,2,2),imagescRGB(imageIncreaseImageRGBSize(desiredImg,20));
% figure; plot(pred(:),targetMacbeth(:),'.'); grid on

end
