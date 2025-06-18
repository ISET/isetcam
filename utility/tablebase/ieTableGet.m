function [files,tRows] = ieTableGet(T,varargin)
% Return the rows that match the conditions in varargin
%
% Synopsis
%   [files,tableRows] = ieTableGet(T,varargin)
%
% Brief
%   We sometimes manage data using tables with variables.  We use this
%   function to retrieve rows of the table whose fields match the specified
%   variables.
%
% Inputs
%   T - A table 
%
% Optional key/val pairs
%   operator - Either 'and' or 'or'.  Default: 'and'
%
%   fields - The table field names with a specified condition are all
%            permissible for the field. The field strings should be lower
%            case in this ISETCam environment.
%
%   return - Type of data to be returned.  By defult, it is the rows of the
%            table ('table rows').  It can be the data files (T.file)
%            assocated with the rows. 
%
% Return
%   files - String array of file names matching the condition(s)
%   tRows - The rows of the table that were selected
%
% Description:
%
%   The data table, T, has metadata fields and usually a slot for the data
%   file. We use this function, ieTableGet, to retrieve the subset of table
%   rows whose fields match the values specified in the input arguments. We
%   can also ask ieTableGet to return an array of strings with the file
%   names that match.
%
%   The varargin fields beyond 'operator' and 'return' must be a table
%   field name and value.  The same field name can be used multiple times
%   when the operation is an 'or'.  For an 'and' operation, multiple field
%   names is likely to lead to an empty return.
%
% See also
%   table

% Example:
%{
% ewave 415 or 450 and substrate tongue and subject J
T = oeDatabaseCreate;
[~,tRows] = ieTableGet(T,'ewave',415,'ewave',450,'operator','or');
files = ieTableGet(tRows,'substrate','tongue','subject','J');
disp(files);
%}
%{
% Subject J or Z.  Ewave 405 or 415.  Substrate tongue.
T = oeDatabaseCreate;
[~,tRows] = ieTableGet(T,'subject','J','subject','Z','operator','or');
[~,tRows] = ieTableGet(tRows,'ewave',405,'ewave',415,'operator','or');
[files,tRows] = ieTableGet(tRows,'substrate','tongue');
%}

%% Parse
% Force the fields to lower case
varargin = ieParamFormat(varargin);

assert(isa(T,'table'));
variableNames = T.Properties.VariableNames;
variableTypes = varfun(@class, T, 'OutputFormat', 'cell');

p = inputParser;
p.addRequired('T',@istable);
p.addParameter('operator','and',@(x)(ismember(x,{'and','or'})));
p.KeepUnmatched = true;

p.parse(T,varargin{:});
op = p.Results.operator;

%% Walk through conditions in varargin

% If the varargin entry is a variable name, then process it.

rows = [];
for ii=1:2:numel(varargin)
    if ismember(varargin{ii},{'operator','return'})
        % do nothing
    else
        % Find the argument and its type.
        [~,idx] = ismember(varargin{ii},variableNames);
        if isempty(idx), error('%d: %s is not a variable name.',ii,varargin{ii});
        else, thisV = variableNames{idx}; thisT = variableTypes{idx}; val = varargin{ii+1}; end

        switch thisT
            case 'string'
                tmp = find(T.(thisV) == val);
            case 'double'
                tmp = find(T.(thisV) == val);
        end

        switch op
            case 'and'
                if isempty(rows), rows = tmp;
                else,             rows = intersect(rows,tmp);
                end

            case 'or'
                if isempty(rows), rows = tmp;
                else,             rows = unique(cat(1,rows,tmp));
                end

            otherwise
                error('Unknown operator %s\n',op);
        end
    end
end

tRows = T(rows,:);
files = T(rows,:).file;

end
