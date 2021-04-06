function sensor = sensorFromFile(filename)
%SENSORFROMFILE Simply retrieve a sensor struct from a file
%   this is mostly needed because we have stored sensors as
%   both isa and sensor structs over the years
%
%   Usage:
%    sensor = sensorFromFile(filename) % kind of like it says:)
%
%   History:
%     Original (if trivial) version: D.Cardinal 12/2020

fullName = fullfile(filename);

sensorNames = {'isa', 'sensor'};
% turn off warnings because matlab hates us using the variable isa now
warning('off');
dataArray = load(fullName,sensorNames{:});

if isfield(dataArray, 'isa')
    sensor = dataArray.isa;
elseif isfield(dataArray,'isa_')
    sensor = dataArray.isa_;
elseif isfield(dataArray, 'sensor')
    sensor = dataArray.sensor;
end
warning('on');
end

