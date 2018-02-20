function isa = sensorDeleteFilter(isa,whichFilter)
% Delete a color filter. 
%
%   isa = sensorDeleteFilter(isa,[whichFilter])
%
%  The filterspectra, filternames and pattern
%  fields are adjusted in the isa structure.  If whichFilter is omitted,
%  the user is queried for a filter name.  The name can be seen on the
%  sensorDesignCFA plot window.
%
% Examples:
%    [val,isa] = vcGetSelectedObject('ISA');
%    isa = sensorDeleteFilter(isa,4);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('isa'), [val,isa] = vcGetSelectedObject('ISA'); end

if ieNotDefined('whichFilter') 
    filterNames = sensorGet(isa,'filterNames');
    deleteName = ieReadString('Enter filter name to replace:',filterNames{1}); 
    if isempty(deleteName), return; end;
    whichFilter = strmatch(deleteName,filterNames);     
    if isempty(whichFilter), return; end;
end

filterSpectra = sensorGet(isa,'filterspectra');
nFilters = sensorGet(isa,'nfilters');

keepList = ones(1,nFilters);
keepList(whichFilter) = 0;
keepList = logical(keepList);
isa = sensorSet(isa,'filterspectra',filterSpectra(:,keepList));

% The pattern terms bigger than or equal to whichFilter all move down one.
% The ones lower than whichFilter stay the same.
pattern = sensorGet(isa,'pattern');
l = find(pattern >= whichFilter);
pattern(l) = max(1,pattern(l)-1);
isa = sensorSet(isa,'pattern',pattern);

filterNames = sensorGet(isa,'filternames');
filterNames = filterNames(keepList);
isa = sensorSet(isa,'filternames',filterNames);

return;

