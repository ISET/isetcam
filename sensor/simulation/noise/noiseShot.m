function [noisyImage,theNoise] = noiseShot(sensor)
% Add shot noise (Poisson electron noise) into the image data
%
%    [noisyImage,theNoise] = noiseShot(sensor)
%
% The shot noise is Poisson in units of electrons (but not in other
% units). Hence, we transform the (mean) voltage image to electrons,
% create the Poisson noise, and then the signal back to a voltage. The
% returned noisy voltage signal is not Poisson; it has the same SNR
% (mean/sd) as the electron image.
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
% Updated 2015, 2022, Stanford University

% Examples:
%{
  scene = sceneCreate;
  scene = sceneSet(scene,'fov',2);
  oi = oiCreate;
  oi = oiCompute(oi,scene);
  sensor = sensorCreate;
  sensor = sensorCompute(sensor,oi);
  sensorWindow(sensor);
  [noisyImage, theNoise] = noiseShot(sensor);
  ieNewGraphWin; imagesc(theNoise); colormap(gray(64))
%}

%% Get the electrons from the sensor
electronImage    = sensorGet(sensor,'electrons');

% Calculate noise using a Gaussian approximation to the Poisson.
% Each point has a standard deviation of the sqrt(mean) value
% The noise will be added (later) to the mean value.
% We do not call Poisson because it is about 3x slower, even accounting for
% all the sqrts.
electronNoise = sqrt(electronImage) .* randn(size(electronImage));

% The Poisson approximation is not absolutely great if the mean is less
% than 20.  We use the real Poisson for those values
poissonCriterion = 25;

% Sometimes there are no sites with a low count.
% In that case, we do not need to compute Poisson noise
if ~isempty(find(electronImage < poissonCriterion,1))
    
    % We have low counts.  Here are the locations 
    v = (electronImage < poissonCriterion);

    % Poisson noise at those locations.
    poissonImage = poissrnd(electronImage .* v);

    % Replace the Gaussian locations with the Poisson values
    % NOTE:  We subject the electronImage from these values because we add
    % it back in later when calculating the noisyImage
    electronNoise(v) = poissonImage(v) - electronImage(v);
end

% Electron counts are discrete, so we round.

% Convert the electron data into voltage signals
conversionGain = sensorGet(sensor,'pixel conversion gain');

% In volts, needs both conversion Gain and Sensor analog gain
%
noisyImage = conversionGain*round(electronImage + electronNoise);
theNoise   = conversionGain*electronNoise;

end
