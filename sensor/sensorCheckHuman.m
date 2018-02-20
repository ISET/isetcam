function bool = sensorCheckHuman(sensor)
%Determine if this is a human sensor model
%
%   bool = sensorCheckHuman(sensor)
%
% (c) Imageval Consulting, LLC 2012

bool = 0;
if ieNotDefined('sensor'), error('sensor required'); end

if     strfind(sensorGet(sensor,'name'),'human'), bool = 1; return; 
elseif isfield(sensor,'human'), bool = 1; return;
end

return