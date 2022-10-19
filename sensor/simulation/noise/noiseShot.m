function [noisyImage,theNoise] = noiseShot(sensor)
% Add shot noise (Poisson electron noise) into the image data
%
%    [noisyImage,theNoise] = noiseShot(sensor)
%
% The shot noise is Poisson in units of electrons (but not in other units).
% Hence, we transform the (mean) voltage image to electrons, create the
% Poisson noise, and then the signal back to a voltage. The returned
% voltage signal is not Poisson; it has the same SNR (mean/sd) as the
% electron image.
%
% This routine uses the normal approximation to the Poisson when there are
% more than 25 electrons in the pixel.  It uses the Poisson distribution
% when there are fewer than 25 electrons.  The Poisson function we have is
% slow for larger means, so we separate the calculation this way.  If we
% had a fast enough Poisson generator, we could use it throughout.
%
% NOTE: This code relies on the Stats toolbox for poissrnd (which
% unfortunately is still slower than our Gaussian approximation
% for larger values)
%
% See also:  poissrnd
%
% Examples:
%    [noisyImage,theNoise] = noiseShot(vcGetObject('sensor'));
%    imagesc(theNoise); colormap(gray(64))
%
% Copyright ImagEval Consultants, LLC, 2003.
% Updated 2015, 2022, Stanford University

volts          = sensorGet(sensor,'volts');
conversionGain = pixelGet(sensor.pixel,'conversion gain');
electronImage  = volts/conversionGain;

% calculate an average "mean" noise as an approximation
meanNoise = sqrt(electronImage) .* randn(size(electronImage));

poissonCriterion = 25;
% photosites where we want to use the Poisson Noise instead
v = electronImage < poissonCriterion;
% we don't always need to compute Poisson noise
if ~isempty(v)
    poissonImage = poissrnd(electronImage .* v);
    meanNoise = meanNoise .* ~v;
    meanImage = electronImage .* ~v;
    % Add our partial arrays together to get the entire image
    % NB: round() was used in original code when adding Gaussian noise
    noisyImage = poissonImage + round(meanImage + meanNoise);
else
    % We add the image + noise electrons together.
    noisyImage = round(electronImage + meanNoise);
end

% Convert the noisy electron image back into the voltage signal
noisyImage = conversionGain*noisyImage;

% return noise also
theNoise = noisyImage - electronImage;


