function dCell = cellDelete(c,dList)
% Delete some cells from a list of cells 
%
%   dCell = cellDelete(c,dList);
%
%Purpose:
%  Delete a the cell entries in the integer list, dList.  Return the
%  (shortened) cell array. 
%
% Example:
%  a = {'a','b','c','d'}; b = cellDelete(a,[1,3]);
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('c'), error('Cell required.'); end
if ieNotDefined('dList'), error('Delete list required.'); end

if max(dList) > length(c) | min(dList < 1), error('Bad dList'); end

% there is actually a simple and much faster way to do that:
dCell = c;
dCell(dList)=[];

% keepList = logical(ones(1,length(c)));
% keepList(dList) = 0;
% 
% % For some reason, cell arrays don't use the cell{keepList} syntax.  So, we
% % loop.
% jj = 1; dCell = [];
% for ii=1:length(keepList)
%     if keepList(ii)
%         dCell{jj} = c{ii};
%         jj = jj+1;
%     end
% end
    
end

% Debug
% a = {'a','b','c','d'};
% cellDelete(a,[1,3])
