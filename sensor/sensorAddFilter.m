function isa = sensorAddFilter(isa,fname)
%Add a color filter to the list of ISA filters
%
%   isa = sensorAddFilter(isa)
%
% The color filter is added to the isa.color.filterSpectra list.  The data
% are read from a file.  This routine is used when editing the color
% filters in the sensorImageWindow.
%
% Examples:
%    isa = vcGetObject('ISA');
%    isa = sensorAddFilter(isa);
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('isa'), [val,isa] = vcGetSelectedObject('ISA'); end
if ieNotDefined('fname'), fname = []; end

wave = sensorGet(isa,'wave');
filterNames = sensorGet(isa,'filterNames');
nFilters = sensorGet(isa,'nfilters');

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
isa = sensorSet(isa,'editFilterNames',length(filterNames)+1,newFilterName);

% Add the filter data to filterSpectra
filterSpectra = sensorGet(isa,'filterspectra');
filterSpectra(:,(nFilters+1)) = data;
isa = sensorSet(isa,'filterspectra',filterSpectra);

return;

