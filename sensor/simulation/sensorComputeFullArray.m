function volts = sensorComputeFullArray(sensor, oi, cFilters)
%Compute voltages for full spatial samples and multiple filters
%
%  volts = sensorComputeFullArray(sensor,oi,[cFilters])
%
% sensor:   ISET sensor
% oi:       ISET optical image
% cFilters: Color filters in the columns.  If not included, then the color
%           filters in the sensor are used.
%
% volts: The returned multidimensional  array has one image plane for each
% of the cFilters.  The spatial array has the same size as the sensor
% (rows,cols).
%
% Example:
%   scene  = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);
%   sensor = sensorCreate; sensor = sensorSetSizeToFOV(sensor,10);
%   sensor = sensorSet(sensor,'noise flag',0);
%   v = sensorComputeFullArray(sensor,oi);
%   vcNewGraphWin; imagesc(v)
%
% (c) Stanford VISTA Team 2012

%%
if ieNotDefined('sensor'), error('Monochrome sensor required'); end
if ieNotDefined('oi');
    error('Optical image required');
end
if ieNotDefined('cFilters')
    cFilters = sensorGet(sensor, 'color filters');
    fprintf('Using %i color filters from the sensor.\n', size(cFilters, 2));
end

%%
sz = sensorGet(sensor, 'size');
numChannels = size(cFilters, 2);
volts = zeros(sz(1), sz(2), numChannels);
sensor = sensorSet(sensor, 'pattern', 1); % Makes it a monochrome array

%%
for kk = 1:numChannels

    s = sensorSet(sensor, 'filterspectra', cFilters(:, kk));
    s = sensorSet(s, 'Name', sprintf('Channel-%.0f', kk));
    s = sensorCompute(s, oi, 0);

    volts(:, :, kk) = sensorGet(s, 'volts');
end

end