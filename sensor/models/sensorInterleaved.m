function sensor = sensorInterleaved(sensor,filterPattern,filterFile)
%
%   Create a default interleaved image sensor array structure.

sensor = sensorSet(sensor,'name',sprintf('interleaved-%.0f',vcCountObjects('sensor')));
sensor = sensorSet(sensor,'cfaPattern',filterPattern);

% Read in a default set of filter spectra
% [filterSpectra,filterNames] = sensorReadColorFilters(sensor,filterFile);
if ischar(filterFile) && exist(filterFile,'file')
    [filterSpectra,filterNames] = sensorReadColorFilters(sensor,filterFile);
elseif isstruct(filterFile)
    filterSpectra = filterFile.data;
    filterNames   = filterFile.filterNames;
    filterWave    = filterFile.wavelength;
    extrapVal = 0;
    filterSpectra = interp1(filterWave, filterSpectra, sensorGet(sensor,'wave'),...
        'linear',extrapVal);
else
    error('Bad format for filterFile variable.');
end

sensor = sensorSet(sensor,'filterSpectra',filterSpectra);
sensor = sensorSet(sensor,'filterNames',filterNames);

end