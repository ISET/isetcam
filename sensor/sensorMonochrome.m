function sensor = sensorMonochrome(sensor, filterFile)
%
%   Create a default monochrome image sensor array structure.
%
% Copyright Imageval Consulting, LLC 2015

% Used in sensorCreate('monochrome')
%

sensor = sensorSet(sensor, 'name', sprintf('monochrome-%.0f', vcCountObjects('sensor')));

[filterSpectra, filterNames] = sensorReadColorFilters(sensor, filterFile);
sensor = sensorSet(sensor, 'filterSpectra', filterSpectra);
sensor = sensorSet(sensor, 'filterNames', filterNames);

sensor = sensorSet(sensor, 'cfaPattern', 1); % 'bayer','monochromatic','triangle'

return;