function sensor = sensorAddFilter(sensor,fname)
% Add a color filter to the list of ISA filters
%
% Synopsis
%   sensor = sensorAddFilter(sensor)
%
% Description
%  The color filter are read from a file and added to the
%  sensor.color.filterSpectra list. This routine is used when editing the
%  color filters in the sensorWindow.
%
% Inputs
%
% Output
%   sensor:  Modified sensor
%
%
% Examples:
%    sensor = ieGetObject('sensor');
%    sensor = sensorAddFilter(sensor);
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also
%    sensorDesignCFA_App.mlapp

if ieNotDefined('isa'), sensor = ieGetObject('ISA'); end
if ieNotDefined('fname'), fname = []; end

wave = sensorGet(sensor,'wave');
filterNames = sensorGet(sensor,'filterNames');
nFilters = sensorGet(sensor,'nfilters');

[data,newFilterNames] = ieReadColorFilter(wave,fname);
if isempty(data), disp('User canceled.'); return; end

nCols = size(data,2);

if nCols > 1
    str=sprintf('Data contains %.0f columns.  Choose one.', nCols);
    whichColumn = ieReadNumber(str);
    if isempty(whichColumn), return; end
    data = data(:,whichColumn);
else
    whichColumn = 1;
end

% Add the filter name to filterNames
newFilterName = char(newFilterNames{whichColumn});
sensor = sensorSet(sensor,'editFilterNames',length(filterNames)+1,newFilterName);

% Add the filter data to filterSpectra
filterSpectra = sensorGet(sensor,'filter spectra');
filterSpectra(:,(nFilters+1)) = data;
sensor = sensorSet(sensor,'filter spectra',filterSpectra);

end

