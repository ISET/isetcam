function S = ieStructRemoveEmptyField(S)
% Utility to remove empty fields from a cell array of structs
%
% Synopsis
%  S = ieStructRemoveEmptyField(S)
%
% Brief description
%   This is useful when writing out JSON files where empty fields get
%   annoying.
%
% Input
%   S - cell array of structs
%
% Outputs
%   S - cell array of the structs with the empty fields removed
%
% See also
%
% Zheng, Brian

% Examples:
%{
S{1}.A = 'x' ; S{1}.B = [] ; S{1}.C  = 1:5 ;
S{2}.A = '' ; S{2}.B = 1 ; S{2}.C  = 1:5 ;
for ii=1:numel(S)
    S{ii} = ieStructRemoveEmptyField(S{ii});
end
%}

% Find all the field names
fn = fieldnames(S);

% See which ones are empty
tf = cellfun(@(c) isempty(S.(c)), fn);

% Remove the empty ones
S = rmfield(S, fn(tf));

end