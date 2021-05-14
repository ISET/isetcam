function EV = exposureValue(optics,isa);
%Compute exposure value for current optics and image sensor array
%
%     EV = exposureValue(optics,isa);
%
%  Exposure value depends on f-number and exposure duration.
%
%      EV = log_2( (f#)^2 / expT )
%
%  where
%   f#   is the f-number of the optics
%   expT is the exposure duration in seconds
%
%Example:
%   optics = vcGetObject('optics'); ISA = vcGetObject('sensor');
%   exposureValue(optics,ISA)
%
% Copyright ImagEval Consultants, LLC, 2005

if ieNotDefined('optics'), optics = vcGetObject('optics'); end
if ieNotDefined('isa'),    isa= vcGetObject('ISA'); end

T = sensorGet(isa,'exposureduration');
F = opticsGet(optics,'fnumber');

EV = log2(F^2/T);

return;