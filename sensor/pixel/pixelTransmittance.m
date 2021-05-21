function [opticalImage,pixel,optics] = pixelTransmittance(opticalImage,pixel,optics);
%
% [opticalImage,pixel,optics] = pixelTransmittance(opticalImage,pixel,optics);
%
% AUTHOR:	PC
% DATE: 	06/20/2003
% PURPOSE:
%   Apply the transmittance of the dielectric layers between the pixel surface
%   and the pixel photodetector in the substrate
%

% Setting up local variables
irradianceImage = sceneGet(opticalImage,'photons');
nWaves = sceneGet(opticalImage,'nWaves');
wave = sceneGet(opticalImage,'wave');
n = pixelGet(pixel,'refractiveindex');
d = pixelGet(pixel,'layerthickness');
fNumber = opticsGet(optics,'fnumber');
incidenceAngles = linspace(-atan(1/(2*fNumber)),atan(1/(2*fNumber)),25);

%  d is in meters
% wave is in nanometers
tunnel = ptTransmittance(n,d,wave,incidenceAngles);

% Applying the pixel transmittance correction
for ii=1:nWaves
    filteredIrradianceImage(:,:,ii) = ...
        tunnel.transmission.spectra * irradianceImage(:,:,ii);
end
opticalImage.data.photons = filteredIrradianceImage;

return