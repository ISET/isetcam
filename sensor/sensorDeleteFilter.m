function sensor = sensorDeleteFilter(sensor,whichFilter)
% Delete a color filter.
%
% Synopsis
%   sensor = sensorDeleteFilter(sensor,[whichFilter])
%
% Brief description
%  The filterspectra, filternames and pattern fields are adjusted in a
%  sensor structure.  If whichFilter is omitted, the user is queried for a
%  filter name (a string).  The name can be seen on the sensorDesignCFA
%  plot window.
%
%  Adjustments to the pattern field may not be right because, well, who
%  knows what the user may intend?
%
% Inputs:
%   sensor:       An ISETCam sensor structure
%   whichFilter:  Integer indicating the filter (column of the filter
%                 spectra)
%
% Outputs:
%
%
% Examples:
%    [val,isa] = vcGetSelectedObject('ISA');
%    isa = sensorDeleteFilter(isa,4);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('sensor'), sensor = ieGetObject('ISA'); end

if ieNotDefined('whichFilter')
    filterNames = sensorGet(sensor,'filterNames');
    deleteName = ieReadString('Enter filter name to replace:',filterNames{1});
    if isempty(deleteName), return; end
    whichFilter = find(strcmpi(deleteName,filterNames));
    if isempty(whichFilter), return; end
end

filterSpectra = sensorGet(sensor,'filterspectra');
nFilters = sensorGet(sensor,'nfilters');

keepList = ones(1,nFilters);
keepList(whichFilter) = 0;
keepList = logical(keepList);
sensor   = sensorSet(sensor,'filterspectra',filterSpectra(:,keepList));

% The pattern terms bigger than or equal to whichFilter all move down one.
% The ones lower than whichFilter stay the same.
pattern = sensorGet(sensor,'pattern');
l = find(pattern >= whichFilter);
pattern(l) = max(1,pattern(l)-1);
sensor = sensorSet(sensor,'pattern',pattern);

filterNames = sensorGet(sensor,'filternames');
filterNames = filterNames(keepList);
sensor = sensorSet(sensor,'filternames',filterNames);

end

