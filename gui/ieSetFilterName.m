function filterNames = ieSetFilterName(whichFilter,newFilterName,isa)
%Insert a new filter name into the list of filters in the ISA
%
%  filterNames = ieSetFilterName(whichFilter,newFilterName,[isa])
%
% Purpose:
%   Insert a new filter name into the list of filterNames at the integer
%   valued position whichFilter. whichFilter can be a value greater than
%   the length of the isa filternames, in which case a new name is
%   appended.  If the new name conflicts with an existing name, then it is
%   modified before it is
%   inserted.
%
% Example:
%    filterNames = ieSetFilterName(1,'rDefault')
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO:  This routine should become
%        isa = sensorSet(isa,'editFilterList',whichFilter,newFilterName);

if ieNotDefined('isa'), [val,isa] = vcGetSelectedObject('ISA'); end

filterNames = sensorGet(isa,'filterNames');
filterNames{whichFilter} = 'nofiltername';
filterNames{whichFilter} = ieAdjustFilterName(newFilterName,filterNames,isa); 

return;

%----------------------------------
function newName = ieAdjustFilterName(newName,filterNames,isa)
%
%  newName = ieAdjustFilterName(newName,filterNames)
%
% Purpose:
%  If the first filter name already exists in the list, or the first
%  character color hint already exists, amend the filter name.
%
% Copyright ImagEval Consultants, LLC, 2003.

for ii=1:length(filterNames)
    if strcmp(newName(1),filterNames{1}(1))
        prompt={'Enter a new first letter for this filter:'};
        def={newName(1)};
        dlgTitle='Adjust color hint';
        lineNo=1;
        answer=inputdlg(prompt,dlgTitle,lineNo,def);
        if isempty(answer{1}), return;
        else newName(1) = answer{1};
        end
    end
end

return;
