function [noisyImage,colDSNU,colPRNU] = binNoiseColumnFPN(ISA)
%Apply  column fpn to the voltage in the sensor image 
%
%    [noisyImage,colDSNU,colPRNU] = binNoiseColumnFPN(ISA)
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

% See comments about dv and volts for binning in binNoiseFPN().
dv          = sensorGet(ISA,'volts');
[nRow,nCol] = size(dv);

colDSNU = sensorGet(ISA,'coloffsetfpnvector');
colPRNU = sensorGet(ISA,'colGainFPNVector');
if (isempty(colDSNU) || isempty(colPRNU)) || ...
        (numel(colDSNU) ~= nCol) || ...
        (numel(colPRNU) ~= nCol)
    colDSNU = randn(1,nCol)*colOffsetFPN;       % Offset noise stored in volts
    colPRNU = randn(1,nCol)*colGainFPN + 1;     % Column gain noise
end

noisyImage = dv * diag(colPRNU)  + repmat(colDSNU,nRow,1);

return;