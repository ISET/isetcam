function [noisyImage,theNoise] = binNoiseRead(ISA)
%Add read noise (temporal random noise) into the sensor voltage
%
%    [noisyImage,theNoise] = binNoiseRead(ISA)
%
% The read noise is a Gaussian random variable
%
% The noisy image is returned, and just the noise is returned if desired.
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('ISA'), errordlg('You must specify the image sensor array'); end
dv   = sensorGet(ISA,'digitalValues');

% Read Noise is Gaussian with zero mean and a sd of readNoise (Volts)
sigmaRead = pixelGet(ISA.pixel,'readNoiseVolts');

% Read noise image
theNoise = sigmaRead * randn(size(dv));

% Add image to the voltage image
noisyImage = theNoise + dv;

return;
