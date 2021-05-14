function [noisyImage,dsnuImage,prnuImage] = noiseFPN(sensor)
% Include dsnu and prnu noise into a sensor image
%
%    [noisyImage, dsnuImage, prnuImage] = noiseFPN(sensor)
%
%  This routine adds the dsnu and prnu noise.  (Shot noise is added
%  in noiseShot).
%
%  The DSNU and PRNU act as an additive offset to the voltage image (DSNU)
%  and as a multiplicative gain factor (PRNU).  Specifically, we first
%  compute the mean voltage image.  Then we transform the mean using
%
%      outputVoltage = (1 + PRNU)*meanVolt + DSNU
%
%  where DSNU is a Gaussian random variable with a standard deviation
%  obtained by sensorGet(sensor,'dsnuSigma').  The PRNU is also a Gaussian
%  random variable with a standard deviation of
%  sensorGet(sensor,'prnuSigma'). The dsnuSigma and prnuSigma are set in
%  the sensor window interface.
%
%  This routine permits a zero integration time so that it can be used  for
%  CDS calculations.  In this case, when sensor.integrationTime = 0, no
%  prnuImage is returned because, well, there is no gain.
%
%  In the past, we sometimes stored the DSNU or PRNU image for reuse.
%  Starting July 2011, we moved to always regenerating but setting an
%  initial seed so that we can regenerate all of the noise in exactly the
%  same way.  It may be that we end up having a couple of noise states so
%  that portions of the noise can be generated the same and others not.  We
%  will see.
%
% See also:  noiseShot, noiseRead, sensorComputeNoise
%
% Example:
%    [noisyImage,dsnuImage,prnuImage] = noiseFPN(vcGetObject('sensor'));
%    imagesc(noisyImage); colormap(gray)
%
% Copyright ImagEval Consultants, LLC, 2003.

if ~exist('sensor','var') || isempty(sensor), sensor = vcGetObject('sensor'); end

isaSize         = sensorGet(sensor,'size');
gainSD          = sensorGet(sensor,'prnuLevel');   % This is a percentage
offsetSD        = sensorGet(sensor,'dsnuLevel');   % This is a voltage
integrationTime = sensorGet(sensor,'integrationTime');
AE              = sensorGet(sensor,'autoExposure');

% Get the fixed pattern noise offset
dsnuImage = randn(isaSize)*offsetSD;

% For CDS calculations we can arrive here with all the
% integration times are 0 and autoexposure off.
% We do a special calculation.
if isequal(integrationTime,zeros(size(integrationTime))) && ~AE
    
    % We just return the offset image as the noise.
    noisyImage = dsnuImage;
    if nargout == 3          % Provide a gainFPN image
        % The gainSD is a percentage around the mean.  So divide the
        % gainSD by 100 because the mean is 1.  For example, if the sd
        % is 20 percent, we want the sd of the normal random variable
        % below to be 0.2 (20 percent around a mean of 1).
        prnuImage = randn(isaSize)*(gainSD/100) + 1;
    end
    return;
else
    % This is usual positive integration time
    
    % Compute the gain image.
    % The gain image has variation in the slopes. We multiply these by a
    % gainFPN random variable and then integrate out using the new slopes.
    % The gainSD is a percentage around the mean.  So divide the
    % gainSD by 100 because the mean is 1.  For example, if the sd
    % is 20 percent, we want the sd of the normal random variable
    % below to be 0.2 (20 percent around a mean of 1).
    prnuImage = randn(isaSize)*(gainSD/100) + 1;
    
    nExposures = sensorGet(sensor,'nExposures');
    % This is the formula:
    % slopeImage = voltageImage/integrationTime;
    % noisyImage = (slopeImage .* prnuImage) * integrationTime + dsnuImage;
    % But it is equivalent to the simpler (fewer multiplies) formula:
    voltageImage = sensorGet(sensor,'volts');
    noisyImage   = voltageImage .* prnuImage  + dsnuImage;
    % noisyImage   = voltageImage .* repmat(prnuImage,[1,1,nExposures])  + repmat(dsnuImage,[1,1,nExposures]);
    % std(dsnuImage(:))
end

return;
