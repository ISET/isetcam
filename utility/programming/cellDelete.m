function dCell = cellDelete(c,dList)
% Delete some entries from a cell array 
%
% Syntax
%   dCell = cellDelete(c,dList);
%
% Input
%   c - Cell array
%   dList - integer list of elements to delete
%
% Description
%  Delete some entries from a cell array.  The entries are specified
%  by the integer list, dList.  Return the (shortened) cell array.
%
% See also:
%

% Example:
%{
 a = {'a','b','c','d'}; 
 b = cellDelete(a,[1,3]);
%}

if ieNotDefined('c'), error('Cell required.'); end
if ieNotDefined('dList'), error('Delete list required.'); end

if max(dList) > length(c) || min(dList < 1), error('Bad dList'); end

% there is actually a simple and much faster way to do that:
dCell = c;
dCell(dList)=[];

end

