function combined = appendStruct(aStruct,bStruct)
%APPENDSTRUCT Appends two structures ignoring duplicates
%   Developed to append two structs while handling cases of non-unique
%   fieldnames.  The default keeps the last occurance of the duplicates in
%   the appended structure.

%Check for existence?
if isempty(aStruct)
    combined = bStruct;
elseif isempty(bStruct)
    combined = aStruct;
else
    abStruct = [struct2cell(aStruct); struct2cell(bStruct)];
    abNames = [fieldnames(aStruct); fieldnames(bStruct)];
    [~,iab] = unique(abNames,'last');
    combined = cell2struct(abStruct(iab),abNames(iab));
end