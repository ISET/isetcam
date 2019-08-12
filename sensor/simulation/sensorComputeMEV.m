function sensorMEV = sensorComputeMEV(sensor, oi, varargin)
% Compute with multiple exposure values and return combined response
%
% Syntax
%    sensorMEV = sensorComputeMEV(sensor, oi, varargin)
%
% Brief description
%    The sensor struct has multiple exposure times set.  The returned
%    sensor data are then recombined into a single value using a
%    reconstruction algorithm.
%
% Inputs
%   sensor:
%   oi:
%
% Optional key/value pairs
%   N/A
%
% Returns
%   sensorMEV: The sensor with a single exposure containing the combined
%              values.  The maximum voltage is adjusted to allow for the fact
%              that there were multiple exposure values.
%
% Wandell, 2019
%
% See also
%   sensorCompute
%

% Examples:
%{

%}
%%
p = inputParser;

%% Compute

expTimes = sensorGet(sensor,'exp times');
sensorMEV = sensorCompute(sensor,oi);

%% Reconstruct


end

