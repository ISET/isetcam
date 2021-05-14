function [noisyImage,offsetFPNImage,gainFPNImage] = binNoiseFPN(ISA)
% Include dsnu and prnu noise into a sensor image
%
%    [noisyImage,offsetFPNImage,gainFPNImage] = binNoiseFPN(ISA)
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
%  obtained by sensorGet(ISA,'dsnuSigma').  The PRNU is also a Gaussian
%  random variable with a standard deviation of sensorGet(ISA,'prnuSigma').
%  The dsnuSigma and prnuSigma are set in the sensor window interface.
%
%  This routine permits a zero integration time so that it can be used  for
%  CDS calculations.  In this case, when ISA.integrationTime = 0, no
%  gainFPNImage is returned because, well, there is no gain.
%
% See also:  noiseShot
%
% Example:
%    [noisyImage,offsetFPNImage,gainFPNImage] = noiseFPN(vcGetObject('ISA'));
%    imagesc(noisyImage); colormap(gray)
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('ISA'), ISA = vcGetObject('ISA'); end

% In the binning calculations, the digital values here are not really
% digital values.  They are on their way to being processed to digital
% values. They are still volts, but they do not have the same size as the
% actual sensor.  Since are processing towards the DV, we put the
% calculation in dv on the way to completing the final values.
dv              = sensorGet(ISA,'digitalValues');
isaSize         = size(dv);
gainSD          = sensorGet(ISA,'prnuLevel');   % This is a percentage
offsetSD        = sensorGet(ISA,'dsnuLevel');   % This is a voltage
integrationTime = sensorGet(ISA,'integrationTime');

% Get the fixed pattern noise offset or compute it
offsetFPNImage  = sensorGet(ISA,'dsnuImage');
if ~isequal(size(offsetFPNImage),isaSize)
    offsetFPNImage = randn(isaSize)*offsetSD;
end

% We handle a correlated double-sampling calculation a little differently
% because it has an integration time of 0.
if integrationTime == 0     % CDS calculation.
    % In this case, exp time = 0, the slope variation is irrelevant,
    % and we just return the offset image as the noise.
    noisyImage = offsetFPNImage;
    if nargout == 3          % Provide a gainFPN image
        gainFPNImage = sensorGet(ISA,'prnuImage');
        if isempty(gainFPNImage)
            % The gainSD is a percentage around the mean.  So divide the
            % gainSD by 100 because the mean is 1.  For example, if the sd
            % is 20 percent, we want the sd of the normal random variable
            % below to be 0.2 (20 percent around a mean of 1).
            gainFPNImage = randn(isaSize)*(gainSD/100) + 1;
        end
    end
    return;
else
    % A calculation with a positive integration time
    
    % Get the gain image, or compute it
    % The gain image has variation in the slopes. We multiply these by a
    % gainFPN random variable and then integrate out using the new slopes.
    gainFPNImage = sensorGet(ISA,'prnuImage');
    if ~isequal(size(gainFPNImage),isaSize)
        % See notes about the gain image above
        gainFPNImage = randn(isaSize)*(gainSD/100) + 1;
    end
    
    nExposures = sensorGet(ISA,'nExposures');
    % This is the formula:
    % slopeImage = voltageImage/integrationTime;
    % noisyImage = (slopeImage .* gainFPNImage) * integrationTime + offsetFPNImage;
    % But it is equivalent to the simpler (fewer multiplies) formula:
    
    noisyImage   = dv .* repmat(gainFPNImage,[1,1,nExposures])  + repmat(offsetFPNImage,[1,1,nExposures]);
    % std(offsetFPNImage(:))
end

return;
