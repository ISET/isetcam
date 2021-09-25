function isHuman = sensorCheckHuman(sensor)
%Determine if this is a human sensor model
%
%   isHuman = sensorCheckHuman(sensor)
%
% (c) Imageval Consulting, LLC 2012


isHuman = 0;
if ieNotDefined('sensor'), error('sensor required'); end
sName = sensorGet(sensor,'name');
if (~isempty(sName) && (ieContains(sName,'human'))) || isfield(sensor,'human')
    isHuman = 1;
end

end
