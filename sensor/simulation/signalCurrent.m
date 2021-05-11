function signalCurrentImage = signalCurrent(oi, sensor, wBar)
% Compute the signal current at each pixel position
%
%      signalCurrentImage = signalCurrent(opticalImage,ISA,wBarHandles)
%
%  The signal current is computed from the optical image (OI) and the image
%  sensor array properties (ISA). The units returned are Amps/pixel =
%  (Coulomb/sec)/pixel.
%
%  This is a key routine called by sensorComputeImage and sensorCompute.
%  The routine can compute the current in either the default spatial
%  resolution mode (1 spatial sample per pixel) or in a high-resolution
%  made in which the pixel is modeled as a grid of sub-pixels and we
%  integrate the spectral irradiance field across this grid, weighting it
%  for the light intensity and the pixel.  (The latter, high resolution
%  mode, has not been much used in years).
%
%  The default or high-resolution mode computation is governed by the
%  nSamplesPerPixel parameter in the sensor
%
%        sensorGet(sensor,'nSamplesPerPixel');
%
%  The default mode has a value of 1 and this is the only mode we have used
%  for many years.  Even so, high resolution modes can be computed with
%
%     sensor = sensorSet(sensor,'nSamplesPerPixel',5) or some other value.
%
%  If 5 is chosen, then there is a 5x5 grid placed over the pixel to
%  account for spatial sampling.
%
%  wBar is the handle to the waitbar image.
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also:
%   signalCurrent, SignalCurrentDensity, spatialIntegration

% Programming note.
% It might have been better to do the spatial integration to the pixel in
% the optical domain first, before computing the current density.  Then we
% could apply pixel optics at that stage rather than being limited as we
% are.  See related notes in signalCurrentDensity.

if ieNotDefined('wBar'), showBar = 0;
else, showBar = 1;
end

% signalCurrentDensityImage samples the current/meter with a sample size of
% [nRows x nCols x nColors] that matches the optical image.
% The spatial integration to account for the pixel size happens next.
if showBar, waitbar(0.4, wBar, 'Sensor image: Signal Current Density'); end
signalCurrentDensityImage = SignalCurrentDensity(oi, sensor); % [A/m^2]

if isempty(signalCurrentDensityImage)
    % This should never happen.
    signalCurrentImage = [];
    return;
else
    % Spatially interpolate the optical image with the image sensor array.
    % The optical image values describe the incident rate of photons.
    %
    % It should be possible to super-sample by setting gridSpacing to, say,
    % 0.2.  We could do this in the user-interface some day.  I am not sure
    % that it has much benefit, but it does take a lot more time and
    % memory.
    gridSpacing = 1 / sensorGet(sensor, 'nSamplesPerPixel');
    if showBar, waitbar(0.5, wBar, sprintf('Sensor image: Spatial (grid: %.2f)', gridSpacing)); end
    signalCurrentImage = spatialIntegration(signalCurrentDensityImage, oi, sensor, gridSpacing); % [A]
end

%{
figure
tmp = signalCurrentImage(1:2:end,1:2:end); subplot(2,2,1), hist(tmp(:))
tmp = signalCurrentImage(1:2:end,2:2:end); subplot(2,2,2), hist(tmp(:))
tmp = signalCurrentImage(2:2:end,1:2:end); subplot(2,2,3), hist(tmp(:))
tmp = signalCurrentImage(2:2:end,2:2:end); subplot(2,2,4), hist(tmp(:))
%}

end
