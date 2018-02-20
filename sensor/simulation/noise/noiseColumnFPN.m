function [noisyImage,colDSNU,colPRNU] = noiseColumnFPN(sensor)
%Apply  column fpn to the voltage in the sensor image 
%
%    [noisyImage,colDSNU,colPRNU] = noiseColumnFPN(sensor)
% 
% The column offset (DSNU) is a Gaussian random variable.
%
% The column gain (PRNU) is a random variably around unit slope, i.e.,
%
%      colPRNU = N(0,1)*colPRNU + 1
%
% If the column FPN values are not already computed, they are computed
% here.  Usually, however, the values are computed in sensorImageWindow.
%
% Copyright ImagEval Consultants, LLC, 2003.

nCol         = sensorGet(sensor,'col');
nRow         = sensorGet(sensor,'row');

colOffsetFPN = sensorGet(sensor,'column fpn offset');
colGainFPN   = sensorGet(sensor,'column fpn gain');
voltageImage    = sensorGet(sensor,'volts');

if colOffsetFPN~=0 || colGainFPN~=0  %Skip calculation if no noise
    colDSNU = randn(1,nCol)*colOffsetFPN;       % Offset noise stored in volts
    colPRNU = randn(1,nCol)*colGainFPN + 1;     % Column gain noise
    noisyImage = voltageImage * diag(colPRNU)  + repmat(colDSNU,nRow,1);
else
    noisyImage = voltageImage;
end

return
