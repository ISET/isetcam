function T = imageEsserTransform(sensorQE, targetQE, illuminant, wave)
% Calculate a linear transformation from sensor data to a specified
% target color space.  The transform is computed to optimize the rendering
% of an Esser color checker under a specified illuminant.
%
% SENSORQE is a matrix whose columns contain the sensor spectral quantum efficiencies.
%
% TARGETQE a matrix whose columns are the spectral quantum efficiency for the desired
% system, such as the human visual system (XYZ).
%
% ILLUMINANT: The name of the spectral power distribution of the
% light that illuminates the Macbeth Color Checker. Default is D65.
%
% WAVE:  The sample wavelengths
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('illuminant'), illuminant = 'D65'; end

% Read the MCC surface spectra and a target illuminant, say D65.  Combine them.
%
% fullfile(isetRootPath,'data','surfaces','esserChart');
fName = which('esserChart.mat');
surRef = ieReadSpectra(fName, wave);
illEnergy = ieReadSpectra(illuminant, wave);
illQuanta = Energy2Quanta(wave, illEnergy);

% These are the predicted sensor responses to the surface reflectance
% functions under the illuminant.  The sensorMacbeth is an XW format.
sensorEsser = (sensorQE' * diag(illQuanta) * surRef)';

% These are the desired sensor responses to the surface reflectance
% functions under the illuminant in the internal color space.
% The sensorMacbeth is an XW format.
targetEsser = (targetQE' * diag(illQuanta) * surRef)';

% This is the linear transformation that maps the sensor values into the
% target values, as illustrated in the comment below.
T = pinv(sensorEsser) * targetEsser;

% pred = sensorMacbeth*T;
% predImg = XW2RGBFormat(pred,6,4);
% figure; title('mcc')
% subplot(1,2,1), imagescRGB(imageIncreaseImageRGBSize(predImg,20));
% desiredImg = XW2RGBFormat(targetMacbeth,6,4);
% subplot(1,2,2),imagescRGB(imageIncreaseImageRGBSize(desiredImg,20));
% figure; plot(pred(:),targetMacbeth(:),'.'); grid on

return;
