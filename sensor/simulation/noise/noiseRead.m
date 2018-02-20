function [noisyImage,theNoise] = noiseRead(sensor)
%Add read noise (temporal random noise) into the sensor voltage
%
%    [noisyImage,theNoise] = noiseRead(sensor)
%
% The read noise is a Gaussian random variable
%
% The noisy image is returned
% Also, if requested, the noise (theNoise) is returned.
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('sensor'), errordlg('You must specify the image sensor array'); end
volts   = sensorGet(sensor,'volts');

% Read Noise is Gaussian with zero mean and a sd of readNoise (Volts)
pixel     = sensorGet(sensor,'pixel');
sigmaRead = pixelGet(pixel,'readNoiseVolts'); 

% Read noise image
theNoise = sigmaRead * randn(size(volts));

% Add image to the voltage image
noisyImage = theNoise + volts;
% figure; imagesc(noisyImage); colormap(gray(256))

return;
