function sensor = sensorReplaceFilter(sensor, whichFilter, newFilterFile)
%
%   sensor = sensorReplaceFilter(sensor,[whichFilter],[newFilterFile])
%
% Replace a color filter in the isa color filter list.  The data
% are read from a file.
%
% We don't alter the sensor.cfa.pattern.  We just changed the filter
% transmissivity and the filter name.
%
% Examples:
%    [val,isa] = vcGetSelectedObject('ISA');
%    isa = sensorReplaceFilter(isa);
%
% Copyright Imageval, LLC 2002

if ieNotDefined('isa'), sensor = vcGetObject('sensor'); end
if ieNotDefined('newFilterFile'), newFilterFile = []; end

if ieNotDefined('whichFilter'),
    filterNames = sensorGet(sensor, 'filterNames');
    replaceName = ieReadString('Enter filter name to replace:', filterNames{1});
    if isempty(replaceName), return;
    end;
    whichFilter = validatestring(replaceName, filterNames);
    if isempty(whichFilter), return;
    end;
end

wave = sensorGet(sensor, 'wave');

[data, newFilterNames] = ieReadColorFilter(wave, newFilterFile);
nCols = size(data, 2);
if nCols > 1
    str = sprintf('Data contains %.0f columns.  Choose one.', nCols);
    whichColumn = ieReadNumber(str);
    if isempty(whichColumn) || (whichColumn < 1) || (whichColumn > nCols), return; end
else
    whichColumn = 1;
end

data = data(:, whichColumn);
filterSpectra = sensorGet(sensor, 'filterspectra');
filterSpectra(:, whichFilter) = data;
sensor = sensorSet(sensor, 'filterspectra', filterSpectra);

% Get a new filter name
newFilterName = ieReadString('Enter filter name to replace:', newFilterNames{whichColumn});
sensor = sensorSet(sensor, 'editFilterNames', whichFilter, newFilterName);
% filterNames = ieSetFilterName(whichFilter,newFilterName,isa);
% isa = sensorSet(isa,'filternames',filterNames);


return;
