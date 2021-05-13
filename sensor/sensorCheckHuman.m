function bool = sensorCheckHuman(sensor)
%Determine if this is a human sensor model
%
%   bool = sensorCheckHuman(sensor)
%
% (c) Imageval Consulting, LLC 2012

if ieNotDefined('sensor')
    error('sensor required')
end

sensor_name = sensorGet(sensor,'name');
bool = ieContains(sensor_name, 'human') || isfield(sensor,'human');

return
